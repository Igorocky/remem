open Json_parse

type tagDto = {
    id:float,
    name:string,
}
let parseTagDto:jsonAny=>tagDto = toObj(_, o => {
    id: o->float("id"),
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

module DeleteTags = {
    let name = "deleteTags"

    type req = {
        ids: array<float>
    }

    let parseReq = toObj(_, o => { 
        ids: o->arr("ids", toFloat(_)) 
    })

    type res = GetAllTags.res

    let parseRes = GetAllTags.parseRes
}
