type tagDto = {
    id:string,
    name:string,
}

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
    nfPaused:bool,
    fnPaused:bool,
}

type cardType =
    | Translate

type cardData =
    | Translate(translateCardDto)

type cardDto = {
    id:string,
    isDeleted:bool,
    crtTime:float,
    data:cardData,
}

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
