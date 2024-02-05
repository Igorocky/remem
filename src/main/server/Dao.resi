let initDatabase: Sqlite.database => unit

let getAllTags: Sqlite.database => promise<Dtos.GetAllTags.res>
let createTag: (Sqlite.database, Dtos.CreateTag.req) => promise<Dtos.CreateTag.res>
let deleteTags: (Sqlite.database, Dtos.DeleteTags.req) => promise<Dtos.DeleteTags.res>