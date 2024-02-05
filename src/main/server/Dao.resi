let initDatabase: unit => unit

let getAllTags: unit => promise<Dtos.GetAllTags.res>
let createTag: Dtos.CreateTag.req => promise<Dtos.CreateTag.res>
let deleteTags: Dtos.DeleteTags.req => promise<Dtos.DeleteTags.res>