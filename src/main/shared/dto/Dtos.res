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

type translateCardDto = {
    native:string,
    foreign:string,
    tran:string,
    tagIds:array<string>,
}
let parseTranslateCardDto:jsonAny=>translateCardDto = toObj(_, o => {
    native: o->str("native"),
    foreign: o->str("foreign"),
    tran: o->str("tran"),
    tagIds: o->arr("tagIds", toStr(_)),
})

@tag("cardType")
type cardData =
    | @as("Translate") Translate(translateCardDto)

type cardDto = {
    id:string,
    isDeleted:bool,
    crtTime:float,
    data:cardData,
}
let parseCardDto:jsonAny=>cardDto = toObj(_, o => {
    id: o->str("id"),
    isDeleted: o->bool("isDeleted"),
    crtTime: o->float("crtTime"),
    data: o->obj("data", d => {
        switch d->str("cardType") {
            | _ => Translate(o->any("data")->parseTranslateCardDto)
        }
    }),
})

module CreateTranslateCard = {
    let name = "createTranslateCard"

    type req = translateCardDto

    let parseReq = parseTranslateCardDto

    type res = unit

    let parseRes = _ => ()
}

// module FindCards = {
//     let name = "findCards"

//     type req = {

//     }

//     let parseReq = parseTranslateCardDto

//     type res = unit

//     let parseRes = _ => ()
// }
