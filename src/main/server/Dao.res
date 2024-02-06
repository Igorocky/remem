open Sqlite

module S = DB_schema

let db = ref(makeDatabase("./remem.sqlite"))

let initDatabase = (db:database) => {
    let latestSchemaVersion = 1
    switch db->dbPragma("user_version") {
        | 0 => {
            db->dbPrepare(DB_schema.dbSchemaV1)->stmtRunNp->ignore
            db->dbPragma(`user_version = ${latestSchemaVersion->Int.toString}`)
        }
        | schemaVersion => {
            if (schemaVersion != latestSchemaVersion) {
                Js.Exn.raiseError(
                    `schemaVersion ${schemaVersion->Int.toString} != ${latestSchemaVersion->Int.toString}`
                )
            }
        }
    }
}

let getAllTagsQuery = `select ${S.tagId} id, ${S.tagName} name from ${S.tagTbl}`
let getAllTags = (db:database):promise<Dtos.GetAllTags.res> => {
    Promise.resolve(
        {
            Dtos.GetAllTags.tags: db->dbPrepare(getAllTagsQuery)->stmtAllNp
                ->Array.map(Json_parse.fromJsonExn(_,Dtos.parseTagDto))
        }
        // {
        //     Dtos.GetAllTags.tags: [
        //         {id:1.0, name:"T1"},
        //         {id:2.0, name:"T2"},
        //     ]
        // }
    )
}

let insertTagQuery = `insert into ${S.tagTbl}(${S.tagName}) values (:name)`
let createTag = (db:database, req:Dtos.CreateTag.req):promise<Dtos.CreateTag.res> => {
    db->dbPrepare(insertTagQuery)->stmtRun({"name":req.name})->ignore
    getAllTags(db)
}

let deleteTags = (db:database, req:Dtos.DeleteTags.req):promise<Dtos.DeleteTags.res> => {
    db->dbPrepare(
        `delete from ${S.tagTbl} where id in (`
            ++ Array.make(~length=req.ids->Array.length, "?")->Array.joinWith(",")
            ++ `)`
    )->stmtRun(req.ids)->ignore
    getAllTags(db)
}