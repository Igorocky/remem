let initDatabase: Sqlite.database => unit

let getAllTags: Sqlite.database => promise<Dtos.GetAllTags.res>
let createTag: (Sqlite.database, Dtos.CreateTag.req) => promise<Dtos.CreateTag.res>
let updateTag: (Sqlite.database, Dtos.UpdateTag.req) => promise<Dtos.UpdateTag.res>
let deleteTags: (Sqlite.database, Dtos.DeleteTags.req) => promise<Dtos.DeleteTags.res>