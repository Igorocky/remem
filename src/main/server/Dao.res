open Sqlite

module S = DB_schema_v1

let initDatabase = (db:database) => {
    switch db->dbPragma("user_version") {
        | 0 => {
            db->dbPragma("foreign_keys = ON")->ignore
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
let getAllTags = (db:database):promise<Dtos.GetAllTags.res> => {
    Promise.resolve(
        {
            Dtos.GetAllTags.tags: db->dbPrepare(getAllTagsQuery)->stmtAllNp
                ->Array.map(Json_parse.fromJsonExn(_,Dtos.parseTagDto))
        }
    )
}

let insertTagQuery = `insert into ${S.tag}(${S.tag_name}) values (:name)`
let createTag = (db:database, req:Dtos.CreateTag.req):promise<Dtos.CreateTag.res> => {
    db->dbPrepare(insertTagQuery)->stmtRun(req)->ignore
    getAllTags(db)
}

let updateTagQuery = `update ${S.tag} set ${S.tag_name} = :name where ${S.tag_id} = :id`
let updateTag = (db:database, req:Dtos.UpdateTag.req):promise<Dtos.UpdateTag.res> => {
    db->dbPrepare(updateTagQuery)->stmtRun(req)->ignore
    getAllTags(db)
}

let deleteTags = (db:database, req:Dtos.DeleteTags.req):promise<Dtos.DeleteTags.res> => {
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
let createTranslateCard = (db:database, req:Dtos.CreateTranslateCard.req):promise<Dtos.CreateTranslateCard.res> => {
    Promise.resolve({
        db->dbPrepare(insertCardQuery)->stmtRun({"card_type":S.cardType_Translate->Int.fromString})->ignore
        let cardId = db->dbPrepare("SELECT last_insert_rowid()||'' id")->stmtGetNp
            ->Json_parse.fromJsonExn(Json_parse.toObj(_, Json_parse.str(_, "id")))
        db->dbPrepare(insertTranslateCardQuery)
            ->stmtRun({"cardId":cardId,"native":req.native,"foreign":req.foreign,"tran":req.tran})->ignore
    })
}