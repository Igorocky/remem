open Sqlite
open Json_parse
open Dtos

module S = DB_schema_v1

let mapResultsOfSelect = (rows:array<JSON.t>, mapper:Json_parse.jsonObj=>'a):array<'a> => {
    rows->Array.map(fromJsonExn(_, toObj(_, mapper)))
}

let addParams = (a:Dict.t<'a>, b:Dict.t<'a>):unit => {
    b->Dict.forEachWithKey((v,k) => {
        switch a->Dict.get(k) {
            | Some(_) => Js.Exn.raiseError(`addParams: parameter name conflict for the key '${k}'`)
            | None => a->Dict.set(k,v)
        }
    })
}

let getAllTagsQuery = `select ${S.tag_id}||'' id, ${S.tag_name} name from ${S.tag} order by ${S.tag_name}`
let getAllTags = (db:database):GetAllTags.res => {
    {
        GetAllTags.tags:
            db->dbSelectNp(getAllTagsQuery)->mapResultsOfSelect(r => {
                id: r->str("id"),
                name: r->str("name"),
            })
    }
}

let insertTagQuery = `insert into ${S.tag}(${S.tag_name}) values (:name)`
let createTag = (db:database, req:CreateTag.req):CreateTag.res => {
    db->dbUpdate(insertTagQuery, req)
    getAllTags(db)
}

let updateTagQuery = `update ${S.tag} set ${S.tag_name} = :name where ${S.tag_id} = :id`
let updateTag = (db:database, req:UpdateTag.req):UpdateTag.res => {
    db->dbUpdate(updateTagQuery, req)
    getAllTags(db)
}

let deleteTags = (db:database, req:DeleteTags.req):DeleteTags.res => {
    db->dbUpdate(
        `delete from ${S.tag} where ${S.tag_id} in (`
            ++ Array.make(~length=req.ids->Array.length, "?")->Array.joinWith(",")
            ++ `)`,
        req.ids
    )
    getAllTags(db)
}

let makeJoinsForTagFilter = (
    ~cardTableAlias:string, 
    ~cardToTagAlias:string,
    ~tagParamName:string,
    ~tagIds:array<string>
):(string,Dict.t<JSON.t>) => {
    if (tagIds->Array.length == 0) {
        ("", Dict.make())
    } else {
        let paramNames = Belt_Array.range(0,tagIds->Array.length-1)->Array.map(i => `${tagParamName}${i->Int.toString}`)
        let joins = []
        joins->Array.push(
            `inner join ${S.cardToTag} ${cardToTagAlias}0
                on ${cardTableAlias}.${S.card_id} = ${cardToTagAlias}0.${S.cardToTag_cardId} 
                    and ${cardToTagAlias}0.${S.cardToTag_tagId} = :${paramNames->Array.getUnsafe(0)}`
        )
        for i in 1 to paramNames->Array.length-1 {
            let idx = Int.toString(i)
            joins->Array.push(
                `inner join ${S.cardToTag} ${cardToTagAlias}${idx} 
                    on ${cardToTagAlias}0.${S.cardToTag_cardId} = ${cardToTagAlias}${idx}.${S.cardToTag_cardId} 
                        and ${cardToTagAlias}${idx}.${S.cardToTag_tagId} = :${paramNames->Array.getUnsafe(i)}`
            )
        }
        let params = Js.Dict.fromArray(
            paramNames->Array.mapWithIndex((name,i) => (name, tagIds->Array.getUnsafe(i)->JSON.Encode.string))
        )
        ( joins->Array.joinWith("\n"), params )
    }
}

let getRemainingTags = (db:database, req:GetRemainingTags.req):GetRemainingTags.res => {
    let selectedTagIds = req.selectedTagIds
    if (selectedTagIds->Array.length == 0) {
        getAllTags(db).tags
    } else {
        let selectedTagIds = selectedTagIds->Belt_HashSetString.fromArray->Belt_HashSetString.toArray
        let (joins, params) = makeJoinsForTagFilter(
            ~cardTableAlias="c", 
            ~cardToTagAlias="ct",
            ~tagParamName="tagId",
            ~tagIds=selectedTagIds
        )
        let query = `
            select t.${S.tag_id}||'' id, t.${S.tag_name} name
            from ${S.tag} t
            where
                t.${S.tag_id} not in (${params->Dict.keysToArray->Array.map(name => ":" ++ name)->Array.joinWith(",")})
                and t.${S.tag_id} in (
                    select distinct ct.${S.cardToTag_tagId}
                    from ${S.cardToTag} ct
                    where
                        ct.${S.cardToTag_cardId} in (
                            select c.${S.card_id}
                            from
                                ${S.card} c
                                ${joins}
                            where c.${S.card_deleted} = ${req.deleted?"1":"0"}
                        )
                )
            `
        db->dbSelect(query, params)->mapResultsOfSelect(r => {
            id: r->str("id"),
            name: r->str("name"),
        })
    }
}

let insertTaskMarkQuery = `insert into ${S.taskHist}(${S.taskHist_taskId},${S.taskHist_mark},${S.taskHist_note})
    values(:taskId, :mark, :note)`
let saveTaskMark = (db:database, req:SaveTaskMark.req):SaveTaskMark.res => {
    db->dbUpdate(insertTaskMarkQuery,
        {"taskId":req.taskId, "mark":req.mark, "note":req.note}
    )
}

let makeFindCardsQuery = (filter:cardFilterDto):(string,Dict.t<JSON.t>) => {
    let cardDeletedCondition = switch filter.deleted {
        | Some(deleted) => `( C.${S.card_deleted} = ${deleted?"1":"0"} )`
        | None => "(1=1)"
    }
    let where = [cardDeletedCondition]
    let params = Dict.make()
    params->Dict.set("itemsPerPage", filter.itemsPerPage->Option.getOr(1)->JSON.Encode.int)
    filter.cardIds->Option.forEach(ids => {
        let listOfParams = []
        ids->Array.forEachWithIndex((id,idx) => {
            let paramName = "cardId" ++ idx->Int.toString
            let paramValue = JSON.Encode.string(id)
            params->Dict.set(paramName, paramValue)
            listOfParams->Array.push(":" ++ paramName)
        })
        where->Array.push(`( C.${S.card_id} in (${listOfParams->Array.joinWith(", ")}) )`)
    })
    let (tagJoins,tagParams) = filter.tagIds->Option.map(tagIds => makeJoinsForTagFilter(
        ~cardTableAlias="C", 
        ~cardToTagAlias="tagFilt",
        ~tagParamName="tagId",
        ~tagIds,
    ))->Option.getOr(("", Dict.make()))
    params->addParams(tagParams)
    if (filter.withoutTags->Option.getOr(false)) {
        where->Array.push(`( CT.${S.cardToTag_tagId} is null )`)
    }
    let query = `
        select
            (row_number() over () - 1) / cast(:itemsPerPage as int) page_idx,
            C.${S.card_id}||'' card_id, 
            C.${S.card_deleted} card_deleted, 
            C.${S.card_crtTime} card_crt_time, 
            C.${S.card_type}||'' card_type,
            group_concat(distinct CT.${S.cardToTag_tagId}) tag_ids,
            max(TR.${S.cardTr_native}) tr_native, 
            max(TR.${S.cardTr_foreign}) tr_foreign, 
            max(TR.${S.cardTr_tran}) tr_tran,
            max(case when S.${S.task_typeId} = ${S.taskType_TranslateNf} then S.${S.task_paused} else 0 end) tr_nf_paused,
            max(case when S.${S.task_typeId} = ${S.taskType_TranslateFn} then S.${S.task_paused} else 0 end) tr_fn_paused
        from
            ${S.card} C
            left join ${S.cardToTag} CT on C.${S.card_id} = CT.${S.cardToTag_cardId}
            left join ${S.cardTr} TR on C.${S.card_id} = TR.${S.cardTr_cardId}
            left join ${S.task} S on C.${S.card_id} = S.${S.task_cardId}
            ${tagJoins}
        where ${where->Array.joinWith(" and ")}
        group by C.${S.card_id}, C.${S.card_deleted}, C.${S.card_crtTime}
        order by C.${S.card_crtTime} desc
    `
    let query = switch filter.pageIdx {
        | None => query
        | Some(pageIdx) => {
            params->Dict.set("pageIdx", pageIdx->JSON.Encode.int)
            `
            select * from (
                ${query}
            ) where page_idx = cast(:pageIdx as int)
            order by card_crt_time desc
            `
        }
    }
    (query,params)
}

let emptyArr = []
let findCards = (db:database, req:FindCards.req):FindCards.res => {
    let (query,params) = makeFindCardsQuery(req)
    db->dbSelect(query,params)->mapResultsOfSelect(r => {
        {
            id: r->str("card_id"),
            isDeleted: r->int("card_deleted") > 0,
            crtTime: r->float("card_crt_time"),
            tagIds: r->strOpt("tag_ids")
                ->Option.map(String.split(_, ","))
                ->Option.getOr(emptyArr),
            data:
                if (S.cardType_Translate == r->str("card_type")) {
                    Translate({
                        native: r->strOpt("tr_native")->Option.getOr(""),
                        foreign: r->strOpt("tr_foreign")->Option.getOr(""),
                        tran: r->strOpt("tr_tran")->Option.getOr(""),
                        nfPaused: r->int("tr_nf_paused") > 0,
                        fnPaused: r->int("tr_fn_paused") > 0,
                    })
                } else {
                    Js.Exn.raiseError(`Unexpected card type: ${r->str("card_type")}`)
                },
        }
    })
}

let deleteCardQuery = `update ${S.card} set ${S.card_deleted} = 1 where ${S.card_id} = :id`
let deleteCard = (db:database, req:DeleteCard.req):DeleteCard.res => {
    db->dbUpdate(deleteCardQuery, {"id":req.cardId})
    db->findCards({ cardIds:[req.cardId] })->Array.getUnsafe(0)
}

let restoreCardQuery = `update ${S.card} set ${S.card_deleted} = 0 where ${S.card_id} = :id`
let restoreCard = (db:database, req:RestoreCard.req):RestoreCard.res => {
    db->dbUpdate(restoreCardQuery, {"id":req.cardId})
    db->findCards({ cardIds:[req.cardId] })->Array.getUnsafe(0)
}

let insertCardQuery = `insert into ${S.card}(${S.card_type},${S.card_extId}) values (:card_type,:card_extId)`
let insertCardToTagQuery = `insert into ${S.cardToTag}
    (${S.cardToTag_cardId}, ${S.cardToTag_tagId}) values (:cardId, :tagId)`
let insertTranslateCardQuery = `insert into ${S.cardTr}
    (${S.cardTr_cardId}, ${S.cardTr_native}, ${S.cardTr_foreign}, ${S.cardTr_tran}) 
    values (:cardId, :native, :foreign, :tran)`
let updateTaskPausedQuery = `update ${S.task}
    set ${S.task_paused} = :paused where ${S.task_cardId} = :cardId and ${S.task_typeId} = :typeId`
let createCard = (db:database, req:CreateCard.req):CreateCard.res => {
    dbTransaction(db, () => {
        db->dbUpdate( insertCardQuery, 
            {"card_type":S.cardType_Translate->Int.fromString, "card_extId": Uuid.uuidv4()} )->ignore
        let cardId = db->dbSelectSingleNp("SELECT last_insert_rowid()||'' id")->fromJsonExn(toObj(_, str(_, "id")))
        req.tagIds->Belt_HashSetString.fromArray->Belt_HashSetString.forEach(tagId => {
            db->dbUpdate(insertCardToTagQuery, {"cardId":cardId,"tagId":tagId})->ignore
        })
        switch req.data {
            | Translate(cardData) => {
                db->dbUpdate(
                    insertTranslateCardQuery, 
                    {"cardId":cardId,"native":cardData.native,"foreign":cardData.foreign,"tran":cardData.tran}
                )->ignore
                if (cardData.nfPaused) {
                    db->dbUpdate(updateTaskPausedQuery, 
                        {"cardId":cardId,"typeId":S.taskType_TranslateNf, "paused":1})->ignore
                }
                if (cardData.fnPaused) {
                    db->dbUpdate(updateTaskPausedQuery, 
                        {"cardId":cardId,"typeId":S.taskType_TranslateFn, "paused":1})->ignore
                }
            }
        }
        db->findCards({ cardIds:[cardId] })->Array.getUnsafe(0)
    })
}

let tagsAreEqual = (a:cardDto, b:cardDto):bool => {
    a.tagIds->Array.every(t => b.tagIds->Array.includes(t)) && b.tagIds->Array.every(t => a.tagIds->Array.includes(t))
}

let deleteCardToTagQuery = `delete from ${S.cardToTag} where ${S.cardToTag_cardId} = :cardId`
let updateTranslateCardQuery = `update ${S.cardTr}
    set ${S.cardTr_native} = :native, ${S.cardTr_foreign} = :foreign, ${S.cardTr_tran} = :tran
    where ${S.cardTr_cardId} = :cardId`
let updateCard = (db:database, req:UpdateCard.req):UpdateCard.res => {
    dbTransaction(db, () => {
        let newCard = req
        let cardId = newCard.id
        let oldCard = db->findCards({ cardIds:[cardId] })->Array.getUnsafe(0)
        if (!(tagsAreEqual(oldCard, newCard))) {
            db->dbUpdate(deleteCardToTagQuery, {"cardId":cardId})->ignore
            newCard.tagIds->Belt_HashSetString.fromArray->Belt_HashSetString.forEach(tagId => {
                db->dbUpdate(insertCardToTagQuery, {"cardId":cardId,"tagId":tagId})->ignore
            })
        }
        switch newCard.data {
            | Translate(newCardData) => {
                db->dbUpdate(
                    updateTranslateCardQuery, 
                    {"cardId":cardId,"native":newCardData.native,"foreign":newCardData.foreign,"tran":newCardData.tran}
                )->ignore
                db->dbUpdate(updateTaskPausedQuery,
                    {"cardId":cardId,"typeId":S.taskType_TranslateNf, "paused":newCardData.nfPaused?1:0})->ignore
                db->dbUpdate(updateTaskPausedQuery,
                    {"cardId":cardId,"typeId":S.taskType_TranslateFn, "paused":newCardData.fnPaused?1:0})->ignore
            }
        }
        db->findCards({ cardIds:[cardId] })->Array.getUnsafe(0)
    })
}

let fillDbWithRandomData = (
    db:database,
    ~numOfTags:int,
    ~numOfCardsOfEachType:int,
    ~minNumOfTagsPerCard:int,
    ~maxNumOfTagsPerCard:int,
    ~histLengthPerTask:int,
    ~markProbs:array<(float,int)>,
):unit => {
    let tags = []
    for _ in 1 to numOfTags {
        let tag = ref(Random.randText(
            ~minLen=3,
            ~maxLen=5,
            ~spaceProb=0,
            ~digitProb=0,
        ))
        while (tags->Array.includes(tag.contents)) {
            tag := Random.randText(
                ~minLen=3,
                ~maxLen=5,
            )
        }
        tags->Array.push(tag.contents)
    }
    tags->Array.forEach(tag => db->createTag({name:tag})->ignore)
    let allTagIds = (db->getAllTags).tags->Array.map(tag => tag.id)
    for _ in 1 to numOfCardsOfEachType {
        let card = db->createCard({
            {
                id:"",
                isDeleted:false,
                crtTime:0.0,
                tagIds:Array.make(~length=Js.Math.random_int(minNumOfTagsPerCard,maxNumOfTagsPerCard), "")
                    ->Array.map(_ => allTagIds->Array.getUnsafe(Js.Math.random_int(0,allTagIds->Array.length))),
                data: Translate({
                    native:Random.randText(~minLen=5, ~maxLen=10, ~digitProb=0, ~spaceProb=0)->String.toUpperCase,
                    foreign:Random.randText(~minLen=5, ~maxLen=10, ~digitProb=0, ~spaceProb=0),
                    tran:"[" ++ Random.randText(~minLen=5, ~maxLen=10, ~digitProb=0, ~spaceProb=0) ++ "]",
                    nfPaused:Js.Math.random() < 0.5,
                    fnPaused:Js.Math.random() < 0.5,
                }),
            }
        })
        if (Js.Math.random() < 0.1) {
            db->deleteCard({cardId:card.id})->ignore
        }
    }
    db->dbSelectNp(`select ${S.task_id}||'' ${S.task_id} from ${S.task}`)->mapResultsOfSelect(str(_, S.task_id))
        ->Array.forEach(taskId => {
            for _ in 1 to histLengthPerTask {
                db->saveTaskMark({
                    taskId,
                    mark: Random.randSelect(markProbs),
                    note: "",
                })
            }
        })
}

let initDatabase = (db:database) => {
    db->dbPragma("foreign_keys = ON")->ignore
    switch db->dbPragma("foreign_keys") {
        | 1 => ()
        | _ => Js.Exn.raiseError(`Unable to set foreign_keys = ON`)
    }
    switch db->dbPragma("user_version") {
        | 0 => {
            //Console.log2("S.schemaScript", S.schemaScript)
            db->dbRunScript(S.schemaScript)->ignore
            db->dbPragma(`user_version = ${S.version->Int.toString}`)
        }
        | actualSchemaVersion => {
            if (actualSchemaVersion != S.version) {
                Js.Exn.raiseError(
                    `actualSchemaVersion ${actualSchemaVersion->Int.toString} != ${S.version->Int.toString}`
                )
            }
        }
    }
}