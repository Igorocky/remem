let version = 1

let tag_tbl = "TAG"
let tag_id = "ID"
let tag_name = "NAME"
let tag_crt_time = "CRT_TIME"

let cardType_tbl = "CARD_TYPE"
let cardType_id = "ID"
let cardType_name = "NAME"
let cardType_Translate = "1"

let card_tbl = "CARD"
let card_id = "ID"
let card_type = "TYPE"
let card_deleted = "DELETED"
let card_crt_time = "CRT_TIME"

let cardToTag_tbl = "CARD_TO_TAG"
let cardToTag_card = "CARD"
let cardToTag_tag = "TAG"

let cardTr_tbl = "CARD_TRANSLATE"
let cardTr_id = "CARD_ID"
let cardTr_native = "NATIVE"
let cardTr_foreign = "FOREIGN_"
let cardTr_tran = "TRANSCRIPTION"

let taskType_tbl = "TASK_TYPE"
let taskType_id = "ID"
let taskType_cardType = "CARD_TYPE"
let taskType_name = "NAME"

let taskSch_tbl = "TASK_SCHEDULE"
let taskSch_id = "ID"
let taskSch_card = "CARD"
let taskSch_type = "TASK_TYPE"
let taskSch_updAt = "UPD_AT"
let taskSch_paused = "PAUSED"
let taskSch_delay = "DELAY"
let taskSch_rnd = "RAND"
let taskSch_nextAccInMs = "NEXT_ACCESS_IN_MS"
let taskSch_nextAccAt = "NEXT_ACCESS_AT"

let schemaScript = `
create table ${tag_tbl} (
    ${tag_id} integer primary key,
    ${tag_name} text not null,
    ${tag_crt_time} real not null default ( unixepoch() * 1000 )
) strict;

create table ${cardType_tbl} (
    ${cardType_id} integer primary key,
    ${cardType_name} text not null
) strict;

insert into ${cardType_tbl} (${cardType_id}, ${cardType_name}) values (${cardType_Translate}, 'Translate');

create table ${card_tbl} (
    ${card_id} integer primary key,
    ${card_type} integer references ${cardType_tbl}(${cardType_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
    ${card_deleted} integer check (${card_deleted} in (0,1)),
    ${card_crt_time} real not null default ( unixepoch() * 1000 )
) strict;

create table ${cardToTag_tbl} (
    ${cardToTag_card} integer references ${card_tbl}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
    ${cardToTag_tag} integer references ${tag_tbl}(${tag_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
    unique (${cardToTag_card}, ${cardToTag_tag})
) strict;

create index cardToTag_idx1 on ${cardToTag_tbl}(${cardToTag_card});
create index cardToTag_idx2 on ${cardToTag_tbl}(${cardToTag_tag});

create table ${cardTr_tbl} (
    ${cardTr_id} integer unique references ${card_tbl}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
    ${cardTr_native} text not null default '',
    ${cardTr_foreign} text not null default '',
    ${cardTr_tran} text not null default ''
) strict;

create table ${taskType_tbl} (
    ${taskType_id} integer primary key,
    ${taskType_cardType} integer references ${cardType_tbl}(${cardType_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
    ${taskType_name} text not null
) strict;

insert into ${taskType_tbl} (${taskType_id}, ${taskType_cardType}, ${taskType_name}) 
    values (${cardType_Translate}01, ${cardType_Translate}, 'Native -> Foreign');
insert into ${taskType_tbl} (${taskType_id}, ${taskType_cardType}, ${taskType_name}) 
    values (${cardType_Translate}02, ${cardType_Translate}, 'Foreign -> Native');

create table ${taskSch_tbl} (
    ${taskSch_id} integer primary key,
    ${taskSch_card} integer references ${card_tbl}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
    ${taskSch_type} integer references ${taskType_tbl}(${taskType_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
    ${taskSch_updAt} real not null,
    ${taskSch_paused} integer check (${taskSch_paused} in (0,1)) default 0,
    ${taskSch_delay} text not null,
    ${taskSch_rnd} real not null,
    ${taskSch_nextAccInMs} real not null,
    ${taskSch_nextAccAt} real not null,
    unique (${taskSch_card}, ${taskSch_type})
);

create trigger create_tasks after insert on ${card_tbl} for each row begin
    insert into ${taskSch_tbl} (
        ${taskSch_card}, 
        ${taskSch_type},
        ${taskSch_updAt},
        ${taskSch_delay},
        ${taskSch_rnd},
        ${taskSch_nextAccInMs},
        ${taskSch_nextAccAt}
    )
    select
        /* ${taskSch_card},  */ new.${card_id},
        /* ${taskSch_type}, */ tt.${taskType_id},
        /* ${taskSch_updAt}, */ unixepoch()*1000,
        /* ${taskSch_delay}, */ '1s',
        /* ${taskSch_rnd}, */ 0,
        /* ${taskSch_nextAccInMs}, */ 1000,
        /* ${taskSch_nextAccAt} */ unixepoch()*1000 + 1000
    from ${taskType_tbl} tt
    where tt.${taskType_cardType} = new.${card_type};
end;
`