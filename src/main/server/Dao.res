open Sqlite

module S = DB_schema_v1

let initDatabase = (db:database) => {
    switch db->dbPragma("user_version") {
        | 0 => {
            db->dbPragma("foreign_keys = ON")->ignore
            // Console.log2("S.schemaScript", schemaScript)
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

let getAllTagsQuery = `select ${S.tag_id}||'' id, ${S.tag_name} name from ${S.tag_tbl} order by ${S.tag_name}`
let getAllTags = (db:database):promise<Dtos.GetAllTags.res> => {
    Promise.resolve(
        {
            Dtos.GetAllTags.tags: db->dbPrepare(getAllTagsQuery)->stmtAllNp
                ->Array.map(Json_parse.fromJsonExn(_,Dtos.parseTagDto))
        }
    )
}

let insertTagQuery = `insert into ${S.tag_tbl}(${S.tag_name}) values (:name)`
let createTag = (db:database, req:Dtos.CreateTag.req):promise<Dtos.CreateTag.res> => {
    db->dbPrepare(insertTagQuery)->stmtRun(req)->ignore
    getAllTags(db)
}

let updateTagQuery = `update ${S.tag_tbl} set ${S.tag_name} = :name where ${S.tag_id} = :id`
let updateTag = (db:database, req:Dtos.UpdateTag.req):promise<Dtos.UpdateTag.res> => {
    db->dbPrepare(updateTagQuery)->stmtRun(req)->ignore
    getAllTags(db)
}

let deleteTags = (db:database, req:Dtos.DeleteTags.req):promise<Dtos.DeleteTags.res> => {
    db->dbPrepare(
        `delete from ${S.tag_tbl} where ${S.tag_id} in (`
            ++ Array.make(~length=req.ids->Array.length, "?")->Array.joinWith(",")
            ++ `)`
    )->stmtRun(req.ids)->ignore
    getAllTags(db)
}