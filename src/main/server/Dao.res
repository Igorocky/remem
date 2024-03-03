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
    set ${S.taskSch_paused} = 1 where ${S.taskSch_card} = :cardId and ${S.taskSch_taskType} = :taskType`
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