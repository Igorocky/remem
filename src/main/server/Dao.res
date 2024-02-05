open Sqlite

let db = ref(makeDatabase("./remem.sqlite"))
module S = DB_schema

let initDatabase = () => {
    let db = db.contents
    let latestSchemaVersion = 1
    switch db->dbPragma("user_version") {
        | 0 => {
            db->dbPrepare(DB_schema.dbSchemaV1)->stmtRun->ignore
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
let getAllTags = ():promise<Dtos.GetAllTags.res> => {
    Promise.resolve(
        {
            Dtos.GetAllTags.tags: db.contents->dbPrepare(getAllTagsQuery)->stmtAll
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
let createTag = (req:Dtos.CreateTag.req):promise<Dtos.CreateTag.res> => {
    db.contents->dbPrepare(insertTagQuery)->stmtRunWithParams({"name":req.name})->ignore
    getAllTags()
}

let deleteTagsQuery = `delete from ${S.tagTbl} where id in (:ids)`
let deleteTags = (req:Dtos.DeleteTags.req):promise<Dtos.DeleteTags.res> => {
    db.contents->dbPrepare(deleteTagsQuery)->stmtRunWithParams({"ids":req.ids})->ignore
    getAllTags()
}