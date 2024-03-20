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

module GetRemainingTags = {
    let name = "getRemainingTags"
    type req = {
        deleted:bool,
        selectedTagIds: array<string>,
    }
    type res = array<tagDto>
}

type translateCardDto = {
    native:string,
    foreign:string,
    tran:string,
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
    tagIds:array<string>,
    data:cardData,
}

module CreateCard = {
    let name = "createCard"
    type req = cardDto
    type res = cardDto
}

module UpdateCard = {
    let name = "updateCard"
    type req = cardDto
    type res = cardDto
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

module SaveTaskMark = {
    let name = "saveTaskMark"
    type req = {
        taskId:string,
        mark:float,
        note:string,
    }
    type res = unit
}

type cardFilterDto = {
    itemsPerPage?:int,
    pageIdx?:int,
    deleted?:bool,
    cardIds?:array<string>,
    tagIds?:array<string>,
    withoutTags?:bool,
    // cardType:option<cardType>,
}

module FindCards = {
    let name = "findCards"
    type req = cardFilterDto
    type res = array<cardDto>
}
