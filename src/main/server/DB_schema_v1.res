let version = 1

let tag_tbl = "TAG"
let tag_id = "ID"
let tag_name = "NAME"
let tag_crt_time = "CRT_TIME"

let card_type_tbl = "CARD_TYPE"
let card_type_id = "ID"
let card_type_name = "NAME"

let card_tbl = "CARD"
let card_id = "ID"
let card_type = "TYPE"
let card_paused = "PAUSED"
let card_deleted = "DELETED"
let card_crt_time = "CRT_TIME"

let card_tag_tbl = "card_tag"
let card_tag_card_id = "card_id"
let card_tag_tag_id = "tag_id"

let card_tr_tbl = "card_translate"
let card_tr_id = "card_id"
let card_tr_native = "native"
let card_tr_foreign = "foreign_"
let card_tr_tran = "transcription"

let schemaScript = `
create table ${tag_tbl} (
    ${tag_id} integer primary key,
    ${tag_name} text not null,
    ${tag_crt_time} real not null default ( unixepoch() * 1000 )
) strict;

create table ${card_type_tbl} (
    ${card_type_id} integer primary key,
    ${card_type_name} text not null
) strict;

insert into ${card_type_tbl} (${card_type_id}, ${card_type_name}) values (1, 'Translate');

create table ${card_tbl} (
    ${card_id} integer primary key,
    ${card_type} integer references ${card_type_tbl}(${card_type_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
    ${card_paused} integer check (${card_paused} in (0,1)),
    ${card_deleted} integer check (${card_deleted} in (0,1)),
    ${card_crt_time} real not null default ( unixepoch() * 1000 )
) strict;

create table ${card_tag_tbl} (
    ${card_tag_card_id} integer references ${card_tbl}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
    ${card_tag_tag_id} integer references ${tag_tbl}(${tag_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
    unique (${card_tag_card_id}, ${card_tag_tag_id})
) strict;

create index card_tag_idx1 on ${card_tag_tbl}(${card_tag_card_id});
create index card_tag_idx2 on ${card_tag_tbl}(${card_tag_tag_id});

create table ${card_tr_tbl} (
    ${card_tr_id} integer unique references ${card_tbl}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
    ${card_tr_native} text not null default '',
    ${card_tr_foreign} text not null default '',
    ${card_tr_tran} text not null default ''
) strict;
`