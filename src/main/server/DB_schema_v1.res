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
let card_extId = "EXT_ID"
let card_type = "TYPE"
let card_deleted = "DELETED"
let card_crtTime = "CRT_TIME"

saveScript(`
    create table ${card} (
        ${card_id} integer primary key,
        ${card_extId} text not null unique,
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
    create index cardToTag_idx1 on ${cardToTag}(${cardToTag_tagId});
    create index cardToTag_idx2 on ${cardToTag}(${cardToTag_cardId},${cardToTag_tagId});
`)

let task = "TASK"
let task_id = "ID"
let task_cardId = "CARD_ID"
let task_typeId = "TYPE_ID"
let task_paused = "PAUSED"

saveScript(`
    create table ${task} (
        ${task_id} integer primary key,
        ${task_cardId} integer references ${card}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
        ${task_typeId} integer references ${taskType}(${taskType_id}) ON DELETE RESTRICT ON UPDATE CASCADE,
        ${task_paused} integer check (${task_paused} in (0,1)) default 0,
        unique (${task_cardId}, ${task_typeId})
    ) strict;
`)
saveScript(`
    create trigger create_tasks after insert on ${card} for each row begin
        insert into ${task} (
            ${task_cardId}, 
            ${task_typeId}
        )
        select
            /* ${task_cardId},  */ new.${card_id},
            /* ${task_typeId}, */ tt.${taskType_id}
        from ${taskType} tt
        where tt.${taskType_cardType} = new.${card_type};
    end;
`)

let taskHist = "TASK_HIST"
let taskHist_taskId = "TASK_ID"
let taskHist_time = "TIME"
let taskHist_mark = "MARK"
let taskHist_note = "NOTE"

saveScript(`
    create table ${taskHist} (
        ${taskHist_taskId} integer references ${task}(${task_id}) ON DELETE CASCADE ON UPDATE CASCADE,
        ${taskHist_time} real not null,
        ${taskHist_mark} real not null check (0 <= ${taskHist_mark} and ${taskHist_mark} <= 1),
        ${taskHist_note} text not null default ''
    ) strict;
`)

/* #################### CARD_TRANSLATE ####################################### */

let cardTr = "CARD_TRANSLATE"
let cardTr_cardId = "CARD_ID"
let cardTr_native = "NATIVE"
let cardTr_foreign = "FOREIGN_"
let cardTr_tran = "TRANSCRIPTION"

saveScript(`
    create table ${cardTr} (
        ${cardTr_cardId} integer unique references ${card}(${card_id}) ON DELETE CASCADE ON UPDATE CASCADE,
        ${cardTr_native} text not null default '',
        ${cardTr_foreign} text not null default '',
        ${cardTr_tran} text not null default ''
    ) strict;
`)

let cardTrChg = "CARD_TRANSLATE_CHG"
let cardTrChg_time = "TIME"
let cardTrChg_id = "CARD_ID"
let cardTrChg_extId = "CARD_EXT_ID"
let cardTrChg_native = "NATIVE"
let cardTrChg_foreign = "FOREIGN_"
let cardTrChg_tran = "TRANSCRIPTION"

saveScript(`
    create table ${cardTrChg} (
        ${cardTrChg_time} real not null default ( unixepoch() * 1000 ),
        ${cardTrChg_id} integer not null,
        ${cardTrChg_extId} text not null,
        ${cardTrChg_native} text not null,
        ${cardTrChg_foreign} text not null,
        ${cardTrChg_tran} text not null
    ) strict;
`)
let cardTrChgTriggerBody = `
    begin
        insert into ${cardTrChg} (
            ${cardTrChg_id},
            ${cardTrChg_extId},
            ${cardTrChg_native},
            ${cardTrChg_foreign},
            ${cardTrChg_tran}
        ) values (
            /* ${cardTrChg_id} */ new.${cardTr_cardId},
            /* ${cardTrChg_extId} */ (select ${card_extId} from ${card} where ${card_id} = new.${cardTr_cardId}),
            /* ${cardTrChg_native} */ new.${cardTr_native},
            /* ${cardTrChg_foreign} */ new.${cardTr_foreign},
            /* ${cardTrChg_tran} */ new.${cardTr_tran}
        );
    end;
`
saveScript(`
    create trigger save_chg_hist_for_card_translate_ins after insert on ${cardTr} for each row 
    ${cardTrChgTriggerBody}
`)
saveScript(`
    create trigger save_chg_hist_for_card_translate_upd after update on ${cardTr} for each row 
    when 
        old.${cardTr_native} <> new.${cardTr_native}
        or old.${cardTr_foreign} <> new.${cardTr_foreign}
        or old.${cardTr_tran} <> new.${cardTr_tran}
    ${cardTrChgTriggerBody}
`)

let schemaScript = schemaScripts->Array.joinWith("\n\n")