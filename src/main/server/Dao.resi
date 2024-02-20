open Sqlite

let initDatabase: database => unit

let getAllTags: database => promise<Dtos.GetAllTags.res>
let createTag: (database, Dtos.CreateTag.req) => promise<Dtos.CreateTag.res>
let updateTag: (database, Dtos.UpdateTag.req) => promise<Dtos.UpdateTag.res>
let deleteTags: (database, Dtos.DeleteTags.req) => promise<Dtos.DeleteTags.res>
let createTranslateCard: (database, Dtos.CreateTranslateCard.req) => promise<Dtos.CreateTranslateCard.res>