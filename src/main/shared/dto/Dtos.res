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
    nfPaused:bool,
    nfNextAccAt:float,
    fnPaused:bool,
    fnNextAccAt:float,
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
    tagIds:array<string>,
}

module DeleteCard = {
    let name = "deleteCard"
    type req = {cardId:string}
    type res = cardDto
}

module RestoreCard = {
    let name = "restoreCard"
    type req = {cardId:string}
    type res = cardDto
}

type cardFilterDto = {
    itemsPerPage?:int,
    pageIdx?:int,
    deleted?:bool,
    cardIds?:array<string>,
    // cardType:option<cardType>,
}

module FindCards = {
    let name = "findCards"
    type req = cardFilterDto
    type res = array<cardDto>
}

module CreateTranslateCard = {
    let name = "createTranslateCard"
    type req = {
        cardData:translateCardDto,
        tagIds:array<string>,
    }
    type res = unit
}

// module UpdateCard = {
//     let name = "updateCard"
//     type req = cardDto
//     type res = cardDto
// }
