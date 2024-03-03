open Sqlite
open Json_parse

module S = DB_schema_v1

let initDatabase = (db:database) => {
    db->dbPragma("foreign_keys = ON")->ignore
    switch db->dbPragma("foreign_keys") {
        | 1 => ()
        | _ => Js.Exn.raiseError(`Unable to set foreign_keys = ON`)
    }
    switch db->dbPragma("user_version") {
        | 0 => {
            //Console.log2("S.schemaScript", S.schemaScript)
            db->dbExec(S.schemaScript)->ignore
            db->dbPragma(`user_version = ${S.version->Int.toString}`)
        }
        | actualSchemaVersion => {
            if (actualSchemaVersion != S.version) {
                Js.Exn.raiseError(
                    `actualSchemaVersion ${actualSchemaVersion->Int.toString} != ${S.version->Int.toString}`
                )
            }
        }
    }
}

let getAllTagsQuery = `select ${S.tag_id}||'' id, ${S.tag_name} name from ${S.tag} order by ${S.tag_name}`
let getAllTags = (db:database):Dtos.GetAllTags.res => {
    {
        Dtos.GetAllTags.tags:
            db->dbAllNp(getAllTagsQuery)->Array.map(fromJsonExn(_,toObj(_, o => {
                Dtos.id: o->str("id"),
                name: o->str("name"),
            })))
    }
}

let insertTagQuery = `insert into ${S.tag}(${S.tag_name}) values (:name)`
let createTag = (db:database, req:Dtos.CreateTag.req):Dtos.CreateTag.res => {
    db->dbRun(insertTagQuery, req)->ignore
    getAllTags(db)
}

let updateTagQuery = `update ${S.tag} set ${S.tag_name} = :name where ${S.tag_id} = :id`
let updateTag = (db:database, req:Dtos.UpdateTag.req):Dtos.UpdateTag.res => {
    db->dbRun(updateTagQuery, req)->ignore
    getAllTags(db)
}

let deleteTags = (db:database, req:Dtos.DeleteTags.req):Dtos.DeleteTags.res => {
    db->dbRun(
        `delete from ${S.tag} where ${S.tag_id} in (`
            ++ Array.make(~length=req.ids->Array.length, "?")->Array.joinWith(",")
            ++ `)`,
        req.ids
    )->ignore
    getAllTags(db)
}

let insertCardQuery = `insert into ${S.card}(${S.card_type}) values (:card_type)`
let insertTranslateCardQuery = `insert into ${S.cardTr}
    (${S.cardTr_id}, ${S.cardTr_native}, ${S.cardTr_foreign}, ${S.cardTr_tran}) 
    values (:cardId, :native, :foreign, :tran)`
let insertCardToTagQuery = `insert into ${S.cardToTag}
    (${S.cardToTag_cardId}, ${S.cardToTag_tagId}) values (:cardId, :tagId)`
let pauseTaskQuery = `update ${S.taskSch}
    set ${S.taskSch_paused} = 1 where ${S.taskSch_cardId} = :cardId and ${S.taskSch_taskType} = :taskType`
let createTranslateCard = (db:database, req:Dtos.CreateTranslateCard.req):Dtos.CreateTranslateCard.res => {
    let cardData = req.cardData
    dbTransaction(db, () => {
        db->dbRun( insertCardQuery, {"card_type":S.cardType_Translate->Int.fromString} )->ignore
        let cardId = db->dbGetNp("SELECT last_insert_rowid()||'' id")->fromJsonExn(toObj(_, str(_, "id")))
        db->dbRun(
            insertTranslateCardQuery, 
            {"cardId":cardId,"native":cardData.native,"foreign":cardData.foreign,"tran":cardData.tran}
        )->ignore
        req.tagIds->Array.forEach(tagId => {
            db->dbRun(insertCardToTagQuery, {"cardId":cardId,"tagId":tagId})->ignore
        })
        if (cardData.nfPaused) {
            db->dbRun(pauseTaskQuery, {"cardId":cardId,"taskType":S.taskType_TranslateNf})->ignore
        }
        if (cardData.fnPaused) {
            db->dbRun(pauseTaskQuery, {"cardId":cardId,"taskType":S.taskType_TranslateFn})->ignore
        }
    })()
}

let makeFindCardsQuery = (filter:Dtos.cardFilterDto):string => {
    `
    select * from (
        select
            (row_number() over () - 1) / ${filter.itemsPerPage->Int.toString} page_idx,
            C.${S.card_id} card_id, 
            C.${S.card_deleted} card_deleted, 
            C.${S.card_crtTime} card_crt_time, 
            C.${S.card_type}||'' card_type,
            group_concat(distinct ':'||T.${S.cardToTag_tagId}||':') tag_ids,
            max(CT.${S.cardTr_native}) tr_native, 
            max(CT.${S.cardTr_foreign}) tr_foreign, 
            max(CT.${S.cardTr_tran}) tr_tran,
            max(case when S.${S.taskSch_taskType} = ${S.taskType_TranslateNf} then S.${S.taskSch_paused} else 0 end) tr_nf_paused,
            max(case when S.${S.taskSch_taskType} = ${S.taskType_TranslateFn} then S.${S.taskSch_paused} else 0 end) tr_fn_paused
        from
            ${S.card} C
            left join ${S.cardToTag} T on C.${S.card_id} = T.${S.cardToTag_cardId}
            left join ${S.cardTr} CT on C.${S.card_id} = CT.${S.cardTr_id}
            left join ${S.taskSch} S on C.${S.card_id} = S.${S.taskSch_cardId}
        group by C.${S.card_id}, C.${S.card_deleted}, C.${S.card_crtTime}
        order by C.${S.card_crtTime}
    ) where page_idx = ${filter.pageIdx->Int.toString}
    `
}

let findCards = (db:database, req:Dtos.FindCards.req):Dtos.FindCards.res => {
    db->dbAllNp(makeFindCardsQuery(req))->Array.map(row => fromJsonExn(row, toObj(_, o => {
        {
            Dtos.id: o->str("card_id"),
            isDeleted: o->int("card_deleted") > 0,
            crtTime: o->float("card_crt_time"),
            tagIds: o->strOpt("tag_ids")->Option.map(idsStr => [])->Option.getOr([]),
            data:
                if (S.cardType_Translate == o->str("card_type")) {
                    Translate({
                        Dtos.native: o->str("tr_native"),
                        foreign: o->str("tr_foreign"),
                        tran: o->str("tr_tran"),
                        nfPaused: o->int("tr_nf_paused") > 0,
                        fnPaused: o->int("tr_fn_paused") > 0,
                    })
                } else {
                    Js.Exn.raiseError(`Unexpected card type: ${o->str("card_type")}`)
                },
        }
    })))
}