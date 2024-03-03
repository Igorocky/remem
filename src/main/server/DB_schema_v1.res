let version = 1

let schemaScripts = []
let saveScript = scriptText => schemaScripts->Array.push(scriptText)

let cardType = "CARD_TYPE"
let cardType_id = "ID"
let cardType_name = "NAME"
let cardType_Translate = "1"

saveScript(`
    create table ${cardType} (
        ${cardType_id} integer primary key,
        ${cardType_name} text not null
    ) strict;
`)
saveScript(`
    insert into ${cardType} (${cardType_id}, ${cardType_name}) values (${cardType_Translate}, 'Translate');
`)

let taskType = "TASK_TYPE"
let taskType_id = "ID"
let taskType_name = "NAME"
let taskType_cardType = "CARD_TYPE"
let taskType_TranslateNf = cardType_Translate ++ "01"
let taskType_TranslateFn = cardType_Translate ++ "02"

saveScript(`
    create table ${taskType} (
        ${taskType_id} integer primary key,
        ${taskType_name} text not null,
        ${taskType_cardType} integer references ${cardType}(${cardType_id}) ON DELETE RESTRICT ON UPDATE CASCADE
    ) strict;
`)
saveScript(`
    insert into ${taskType} (${taskType_cardType}, ${taskType_name}, ${taskType_id}) 
        values (${cardType_Translate}, 'Native -> Foreign', ${taskType_TranslateNf});
    insert into ${taskType} (${taskType_cardType}, ${taskType_name}, ${taskType_id}) 
        values (${cardType_Translate}, 'Foreign -> Native', ${taskType_TranslateFn});
`)

let tag = "TAG"
let tag_id = "ID"
let tag_name = "NAME"
let tag_crt_time = "CRT_TIME"

saveScript(`
    create table ${tag} (
        ${tag_id} integer primary key,
        ${tag_name} text not null,
        ${tag_crt_time} real not null default ( unixepoch() * 1000 )
    ) strict;
`)

let card = "CARD"
let card_id = "ID"
let card_type = "TYPE"
let card_deleted = "DELETED"
let card_crtTime = "CRT_TIME"

saveScript(`
    create table ${card} (
        ${card_id} integer primary key,
        ${card_type} integer references ${cardType}(${cardType_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
        ${card_deleted} integer check (${card_deleted} in (0,1)) default 0,
        ${card_crtTime} real not null default ( unixepoch() * 1000 )
    ) strict;
`)

let cardToTag = "CARD_TO_TAG"
let cardToTag_cardId = "CARD_ID"
let cardToTag_tagId = "TAG_ID"

saveScript(`
    create table ${cardToTag} (
        ${cardToTag_cardId} integer references ${card}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
        ${cardToTag_tagId} integer references ${tag}(${tag_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
        unique (${cardToTag_cardId}, ${cardToTag_tagId})
    ) strict;
`)
saveScript(`
    create index cardToTag_idx1 on ${cardToTag}(${cardToTag_cardId});
    create index cardToTag_idx2 on ${cardToTag}(${cardToTag_tagId});
`)

let cardTr = "CARD_TRANSLATE"
let cardTr_id = "CARD_ID"
let cardTr_native = "NATIVE"
let cardTr_foreign = "FOREIGN_"
let cardTr_tran = "TRANSCRIPTION"

saveScript(`
    create table ${cardTr} (
        ${cardTr_id} integer unique references ${card}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
        ${cardTr_native} text not null default '',
        ${cardTr_foreign} text not null default '',
        ${cardTr_tran} text not null default ''
    ) strict;
`)

let taskSch = "TASK_SCHEDULE"
let taskSch_id = "ID"
let taskSch_cardId = "CARD"
let taskSch_taskType = "TASK_TYPE"
let taskSch_paused = "PAUSED"
let taskSch_updAt = "UPD_AT"
let taskSch_delay = "DELAY"
let taskSch_rnd = "RAND"
let taskSch_nextAccInMs = "NEXT_ACCESS_IN_MS"
let taskSch_nextAccAt = "NEXT_ACCESS_AT"

saveScript(`
    create table ${taskSch} (
        ${taskSch_id} integer primary key,
        ${taskSch_cardId} integer references ${card}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
        ${taskSch_taskType} integer references ${taskType}(${taskType_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
        ${taskSch_paused} integer check (${taskSch_paused} in (0,1)) default 0,
        ${taskSch_updAt} real not null,
        ${taskSch_delay} text not null,
        ${taskSch_rnd} real not null,
        ${taskSch_nextAccInMs} real not null,
        ${taskSch_nextAccAt} real not null,
        unique (${taskSch_cardId}, ${taskSch_taskType})
    );
`)
saveScript(`
    create trigger create_tasks after insert on ${card} for each row begin
        insert into ${taskSch} (
            ${taskSch_cardId}, 
            ${taskSch_taskType},
            ${taskSch_updAt},
            ${taskSch_delay},
            ${taskSch_rnd},
            ${taskSch_nextAccInMs},
            ${taskSch_nextAccAt}
        )
        select
            /* ${taskSch_cardId},  */ new.${card_id},
            /* ${taskSch_taskType}, */ tt.${taskType_id},
            /* ${taskSch_updAt}, */ unixepoch()*1000,
            /* ${taskSch_delay}, */ '1s',
            /* ${taskSch_rnd}, */ 0,
            /* ${taskSch_nextAccInMs}, */ 1000,
            /* ${taskSch_nextAccAt} */ unixepoch()*1000 + 1000
        from ${taskType} tt
        where tt.${taskType_cardType} = new.${card_type};
    end;
`)

let schemaScript = schemaScripts->Array.joinWith("\n\n")