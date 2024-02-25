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

    type res = {
        tags:array<tagDto>
    }
}

module CreateTag = {
    let name = "createTag"

    type req = {
        name: string
    }

    type res = GetAllTags.res
}

module UpdateTag = {
    let name = "updateTag"

    type req = tagDto

    type res = GetAllTags.res
}

module DeleteTags = {
    let name = "deleteTags"

    type req = {
        ids: array<string>
    }

    type res = GetAllTags.res
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

type cardType =
    | Translate

let cardTypeToStr = (cardType:cardType) => {
    switch cardType {
        | Translate => "Translate"
    }
}

let strToCardType = (str:string):cardType => {
    switch str {
        | _ => Translate
    }
}

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

    type res = unit
}

module FindCards = {
    let name = "findCards"

    type req = {
        cardType:cardType
    }

    type res = array<cardDto>
}
