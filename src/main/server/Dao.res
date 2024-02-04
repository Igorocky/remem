open Sqlite
open DB_schema

let db = ref(makeDatabase("./remem.sqlite"))

let initDatabase = () => {
    let db = db.contents
    let latestSchemaVersion = 1
    switch db->dbPragma("user_version") {
        | 0 => {
            db->dbPrepare(dbSchemaV1)->stmtRun->ignore
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

let getAllTags = ():promise<Dtos.GetAllTags.res> => {
    Promise.resolve(
        {
            Dtos.GetAllTags.tags: [
                {id:1.0, name:"T1"},
                {id:2.0, name:"T2"},
            ]
        }
    )
}