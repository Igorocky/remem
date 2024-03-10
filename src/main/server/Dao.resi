open Sqlite

let initDatabase: database => unit

let getAllTags: database => Dtos.GetAllTags.res
let createTag: (database, Dtos.CreateTag.req) => Dtos.CreateTag.res
let updateTag: (database, Dtos.UpdateTag.req) => Dtos.UpdateTag.res
let deleteTags: (database, Dtos.DeleteTags.req) => Dtos.DeleteTags.res
let findCards: (database, Dtos.FindCards.req) => Dtos.FindCards.res
let deleteCard: (database, Dtos.DeleteCard.req) => Dtos.DeleteCard.res
let restoreCard: (database, Dtos.RestoreCard.req) => Dtos.RestoreCard.res
let createTranslateCard: (database, Dtos.CreateTranslateCard.req) => Dtos.CreateTranslateCard.res