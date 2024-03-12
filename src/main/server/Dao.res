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
            db->dbRunScript(S.schemaScript)->ignore
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
            db->dbSelectNp(getAllTagsQuery)->Array.map(fromJsonExn(_,toObj(_, o => {
                Dtos.id: o->str("id"),
                name: o->str("name"),
            })))
    }
}

let insertTagQuery = `insert into ${S.tag}(${S.tag_name}) values (:name)`
let createTag = (db:database, req:Dtos.CreateTag.req):Dtos.CreateTag.res => {
    db->dbUpdate(insertTagQuery, req)
    getAllTags(db)
}

let updateTagQuery = `update ${S.tag} set ${S.tag_name} = :name where ${S.tag_id} = :id`
let updateTag = (db:database, req:Dtos.UpdateTag.req):Dtos.UpdateTag.res => {
    db->dbUpdate(updateTagQuery, req)
    getAllTags(db)
}

let deleteTags = (db:database, req:Dtos.DeleteTags.req):Dtos.DeleteTags.res => {
    db->dbUpdate(
        `delete from ${S.tag} where ${S.tag_id} in (`
            ++ Array.make(~length=req.ids->Array.length, "?")->Array.joinWith(",")
            ++ `)`,
        req.ids
    )
    getAllTags(db)
}

let makeFindCardsQuery = (filter:Dtos.cardFilterDto):(string,Dict.t<JSON.t>) => {
    let cardDeletedCondition = switch filter.deleted {
        | Some(deleted) => `( C.${S.card_deleted} = ${deleted?"1":"0"} )`
        | None => "(1=1)"
    }
    let where = [cardDeletedCondition]
    let params = Dict.make()
    filter.cardIds->Option.forEach(ids => {
        let listOfParams = []
        ids->Array.forEachWithIndex((id,idx) => {
            let paramName = "cardId" ++ idx->Int.toString
            let paramValue = JSON.Encode.string(id)
            params->Dict.set(paramName, paramValue)
            listOfParams->Array.push(":" ++ paramName)
        })
        where->Array.push(`( C.${S.card_id} in (` ++ listOfParams->Array.joinWith(", ") ++ ") )")
    })
    let query = `
    select * from (
        select
            (row_number() over () - 1) / ${filter.itemsPerPage->Option.getOr(50)->Int.toString} page_idx,
            C.${S.card_id}||'' card_id, 
            C.${S.card_deleted} card_deleted, 
            C.${S.card_crtTime} card_crt_time, 
            C.${S.card_type}||'' card_type,
            group_concat(distinct ':'||T.${S.cardToTag_tagId}||':') tag_ids,
            max(CT.${S.cardTr_native}) tr_native, 
            max(CT.${S.cardTr_foreign}) tr_foreign, 
            max(CT.${S.cardTr_tran}) tr_tran,
            max(case when S.${S.taskSch_taskType} = ${S.taskType_TranslateNf} then S.${S.taskSch_paused} else 0 end)    tr_nf_paused,
            max(case when S.${S.taskSch_taskType} = ${S.taskType_TranslateNf} then S.${S.taskSch_nextAccAt} else 0 end) tr_nf_next_acc_at,
            max(case when S.${S.taskSch_taskType} = ${S.taskType_TranslateFn} then S.${S.taskSch_paused} else 0 end)    tr_fn_paused,
            max(case when S.${S.taskSch_taskType} = ${S.taskType_TranslateFn} then S.${S.taskSch_nextAccAt} else 0 end)    tr_fn_next_acc_at
        from
            ${S.card} C
            left join ${S.cardToTag} T on C.${S.card_id} = T.${S.cardToTag_cardId}
            left join ${S.cardTr} CT on C.${S.card_id} = CT.${S.cardTr_id}
            left join ${S.taskSch} S on C.${S.card_id} = S.${S.taskSch_cardId}
        where ${where->Array.joinWith(" and ")}
        group by C.${S.card_id}, C.${S.card_deleted}, C.${S.card_crtTime}
        order by C.${S.card_crtTime}
    ) where page_idx = ${filter.pageIdx->Option.getOr(0)->Int.toString}
    `
    (query,params)
}

let emptyArr = []
let findCards = (db:database, req:Dtos.FindCards.req):Dtos.FindCards.res => {
    let (query,params) = makeFindCardsQuery(req)
    let rows = db->dbSelect(query,params)
    rows->Array.map(row => fromJsonExn(row, toObj(_, o => {
        {
            Dtos.id: o->str("card_id"),
            isDeleted: o->int("card_deleted") > 0,
            crtTime: o->float("card_crt_time"),
            tagIds: o->strOpt("tag_ids")
                ->Option.map(String.split(_, ","))
                ->Option.map(strArr => strArr->Array.map(str => str->String.substring(~start=1,~end=str->String.length-1)))
                ->Option.getOr(emptyArr),
            data:
                if (S.cardType_Translate == o->str("card_type")) {
                    Translate({
                        Dtos.native: o->strOpt("tr_native")->Option.getOr(""),
                        foreign: o->strOpt("tr_foreign")->Option.getOr(""),
                        tran: o->strOpt("tr_tran")->Option.getOr(""),
                        nfPaused: o->int("tr_nf_paused") > 0,
                        nfNextAccAt: o->float("tr_nf_next_acc_at"),
                        fnPaused: o->int("tr_fn_paused") > 0,
                        fnNextAccAt: o->float("tr_fn_next_acc_at"),
                    })
                } else {
                    Js.Exn.raiseError(`Unexpected card type: ${o->str("card_type")}`)
                },
        }
    })))
}

let deleteCardQuery = `update ${S.card} set ${S.card_deleted} = 1 where ${S.card_id} = :id`
let deleteCard = (db:database, req:Dtos.DeleteCard.req):Dtos.DeleteCard.res => {
    db->dbUpdate(deleteCardQuery, {"id":req.cardId})
    db->findCards({ cardIds:[req.cardId] })->Array.getUnsafe(0)
}

let restoreCardQuery = `update ${S.card} set ${S.card_deleted} = 0 where ${S.card_id} = :id`
let restoreCard = (db:database, req:Dtos.RestoreCard.req):Dtos.RestoreCard.res => {
    db->dbUpdate(restoreCardQuery, {"id":req.cardId})
    db->findCards({ cardIds:[req.cardId] })->Array.getUnsafe(0)
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
        db->dbUpdate( insertCardQuery, {"card_type":S.cardType_Translate->Int.fromString} )->ignore
        let cardId = db->dbSelectSingleNp("SELECT last_insert_rowid()||'' id")->fromJsonExn(toObj(_, str(_, "id")))
        db->dbUpdate(
            insertTranslateCardQuery, 
            {"cardId":cardId,"native":cardData.native,"foreign":cardData.foreign,"tran":cardData.tran}
        )->ignore
        req.tagIds->Array.forEach(tagId => {
            db->dbUpdate(insertCardToTagQuery, {"cardId":cardId,"tagId":tagId})->ignore
        })
        if (cardData.nfPaused) {
            db->dbUpdate(pauseTaskQuery, {"cardId":cardId,"taskType":S.taskType_TranslateNf})->ignore
        }
        if (cardData.fnPaused) {
            db->dbUpdate(pauseTaskQuery, {"cardId":cardId,"taskType":S.taskType_TranslateFn})->ignore
        }
    })
}