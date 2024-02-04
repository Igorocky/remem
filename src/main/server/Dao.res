open Sqlite
open DB_schema

let db = ref(makeDatabase("./remem.sqlite"))

let initDatabase = () => {
    let db = db.contents
    let latestSchemaVersionStr = "1"
    switch db->dbPragma("user_version") {
        | 0 => {
            db->dbPrepare(dbSchemaV1)->stmtRun->ignore
            db->dbPragma(`user_version = ${latestSchemaVersionStr}`)
        }
        | schemaVersion => {
            if (schemaVersion->Int.toString != latestSchemaVersionStr) {
                Js.Exn.raiseError(`schemaVersion != ${latestSchemaVersionStr}`)
            }
        }
    }
}