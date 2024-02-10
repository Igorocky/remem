open Json_parse

type tagDto = {
    id:string,
    name:string,
}
let parseTagDto:jsonAny=>tagDto = toObj(_, o => {
    id: o->str("id"),
    name: o->str("name"),
})

module GetAllTags = {
    let name = "getAllTags"

    type req = unit

    let parseReq = _ => ()

    type res = {
        tags:array<tagDto>
    }

    let parseRes = toObj(_, o => { 
        tags: o->arr("tags", parseTagDto) 
    })
}

module CreateTag = {
    let name = "createTag"

    type req = {
        name: string
    }

    let parseReq = toObj(_, o => { 
        name: o->str("name") 
    })

    type res = GetAllTags.res

    let parseRes = GetAllTags.parseRes
}

module UpdateTag = {
    let name = "updateTag"

    type req = tagDto

    let parseReq = parseTagDto

    type res = GetAllTags.res

    let parseRes = GetAllTags.parseRes
}

module DeleteTags = {
    let name = "deleteTags"

    type req = {
        ids: array<string>
    }

    let parseReq = toObj(_, o => { 
        ids: o->arr("ids", toStr(_)) 
    })

    type res = GetAllTags.res

    let parseRes = GetAllTags.parseRes
}
