open Sqlite

let tags = "TAGS"
let tagsId = "ID"
let tagsName = "NAME"
let tagsCrtTime = "CRT_TIME"

let db = ref(makeDatabase("./remem.sqlite"))

let initDatabase = () => {
    db.contents->dbPrepare(`
        create table if not exists ${tags} (
            ${tagsId} integer primary key,
            ${tagsName} text not null,
            ${tagsCrtTime} real not null default ( unixepoch() * 1000 )
        ) strict;
    `)->stmtRun->ignore
}