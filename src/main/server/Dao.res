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
            db->dbPrepare(getAllTagsQuery)->stmtAllNp
                ->Array.map(fromJsonExn(_,toObj(_, o => {
                    Dtos.id: o->str("id"),
                    name: o->str("name"),
                })))
    }
}

let insertTagQuery = `insert into ${S.tag}(${S.tag_name}) values (:name)`
let createTag = (db:database, req:Dtos.CreateTag.req):Dtos.CreateTag.res => {
    db->dbPrepare(insertTagQuery)->stmtRun(req)->ignore
    getAllTags(db)
}

let updateTagQuery = `update ${S.tag} set ${S.tag_name} = :name where ${S.tag_id} = :id`
let updateTag = (db:database, req:Dtos.UpdateTag.req):Dtos.UpdateTag.res => {
    db->dbPrepare(updateTagQuery)->stmtRun(req)->ignore
    getAllTags(db)
}

let deleteTags = (db:database, req:Dtos.DeleteTags.req):Dtos.DeleteTags.res => {
    db->dbPrepare(
        `delete from ${S.tag} where ${S.tag_id} in (`
            ++ Array.make(~length=req.ids->Array.length, "?")->Array.joinWith(",")
            ++ `)`
    )->stmtRun(req.ids)->ignore
    getAllTags(db)
}

let insertCardQuery = `insert into ${S.card}(${S.card_type}) values (:card_type)`
let insertTranslateCardQuery = `insert into ${S.cardTr}
(${S.cardTr_id}, ${S.cardTr_native}, ${S.cardTr_foreign}, ${S.cardTr_tran}) 
values (:cardId, :native, :foreign, :tran)`
let insertCardToTagQuery = `insert into ${S.cardToTag}
(${S.cardToTag_cardId}, ${S.cardToTag_tagId}) values (:cardId, :tagId)`
let createTranslateCard = (db:database, req:Dtos.CreateTranslateCard.req):Dtos.CreateTranslateCard.res => {
    db->dbPrepare(insertCardQuery)->stmtRun({"card_type":S.cardType_Translate->Int.fromString})->ignore
    let cardId = db->dbPrepare("SELECT last_insert_rowid()||'' id")->stmtGetNp
        ->Json_parse.fromJsonExn(Json_parse.toObj(_, Json_parse.str(_, "id")))
    db->dbPrepare(insertTranslateCardQuery)
        ->stmtRun({"cardId":cardId,"native":req.native,"foreign":req.foreign,"tran":req.tran})->ignore
    req.tagIds->Array.forEach(tagId => {
        db->dbPrepare(insertCardToTagQuery)->stmtRun({"cardId":cardId,"tagId":tagId})->ignore
    })
}