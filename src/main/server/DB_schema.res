let tagTbl = "TAG"
let tagId = "ID"
let tagName = "NAME"
let tagCrtTime = "CRT_TIME"

let dbSchemaV1 = `
create table if not exists ${tagTbl} (
    ${tagId} integer primary key,
    ${tagName} text not null,
    ${tagCrtTime} real not null default ( unixepoch() * 1000 )
) strict;
`