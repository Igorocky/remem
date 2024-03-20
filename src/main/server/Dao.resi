open Sqlite
open Dtos

let initDatabase: database => unit

let getAllTags: database => GetAllTags.res
let createTag: (database, CreateTag.req) => CreateTag.res
let updateTag: (database, UpdateTag.req) => UpdateTag.res
let deleteTags: (database, DeleteTags.req) => DeleteTags.res
let getRemainingTags: (database, GetRemainingTags.req) => GetRemainingTags.res

let saveTaskMark: (database, SaveTaskMark.req) => SaveTaskMark.res

let findCards: (database, FindCards.req) => FindCards.res
let deleteCard: (database, DeleteCard.req) => DeleteCard.res
let restoreCard: (database, RestoreCard.req) => RestoreCard.res
let createCard: (database, CreateCard.req) => CreateCard.res
let updateCard: (database, UpdateCard.req) => UpdateCard.res

let fillDbWithRandomData: (
    database,
    ~numOfTags:int,
    ~numOfCardsOfEachType:int,
    ~minNumOfTagsPerCard:int,
    ~maxNumOfTagsPerCard:int,
    ~histLengthPerTask:int,
    ~markProbs:array<(float,int)>,
) => unit