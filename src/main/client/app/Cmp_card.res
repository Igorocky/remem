open Mui_components
open React_utils
open BE_utils
open React_rnd_utils
open Modal
open Dtos

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

type state = {
    cardDto:cardDto,
}

let makeInitialCardDto = (cardType:cardType, ~tagIds:option<array<string>>=?) => {
    {
        id:"",
        isDeleted:false,
        crtTime:0.0,
        tagIds:tagIds->Option.getOr([]),
        data:
            switch cardType {
                | Translate => {
                    Translate({
                        native:"",
                        foreign:"",
                        tran:"",
                        nfPaused:false,
                        nfNextAccAt:0.,
                        fnPaused:false,
                        fnNextAccAt:0.,
                    })
                }
            }
    }
}

let makeInitialState = (~cardDto:option<cardDto>):state => {
    switch cardDto {
        | Some(cardDto) => {cardDto:cardDto}
        | None => {
            {
                cardDto:makeInitialCardDto(Translate),
            }
        }
    }
}

let getCurrCardType = (st:state):cardType => {
    switch st.cardDto.data {
        | Translate(_) => Translate
    }
}

let setCardType = (st:state, newCardType:cardType):state => {
    if (st->getCurrCardType == newCardType) {
        st
    } else {
        {cardDto:makeInitialCardDto(newCardType, ~tagIds=st.cardDto.tagIds)}
    }
}

let updateTranslateCardData = (st:state, upd:translateCardDto=>translateCardDto):state => {
    switch st.cardDto.data {
        | Translate(data) => { cardDto: {...st.cardDto, data:Translate(data->upd) }}
    }
}

let setNative = (st:state,text:string):state => {
    updateTranslateCardData(st, data => {...data, native:text})
}

let setForeign = (st:state,text:string):state => {
    updateTranslateCardData(st, data => {...data, foreign:text})
}

let setTran = (st:state,text:string):state => {
    updateTranslateCardData(st, data => {...data, tran:text})
}

let setTagIds = (st:state,tags:array<Dtos.tagDto>):state => {
    {cardDto:{...st.cardDto, tagIds:tags->Array.map(tag => tag.id)}}
}

let setNfPaused = (st:state,paused:bool):state => {
    updateTranslateCardData(st, data => {...data, nfPaused:paused})
}

let setFnPaused = (st:state,paused:bool):state => {
    updateTranslateCardData(st, data => {...data, fnPaused:paused})
}

let createCard:beFunc<Dtos.CreateCard.req, Dtos.CreateCard.res> = createBeFunc(module(Dtos.CreateCard))
let updateCard:beFunc<Dtos.UpdateCard.req, Dtos.UpdateCard.res> = createBeFunc(module(Dtos.UpdateCard))

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
    ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
    ~getRemainingTags:array<Dtos.tagDto>=>promise<result<array<Dtos.tagDto>,string>>,
    ~cardDto:option<cardDto>=?,
    ~onSaved:option<cardDto=>unit>=?,
    ~onCancel:option<unit=>unit>=?,
) => {
    let (state, setState) = React.useState(() => makeInitialState(~cardDto))

    let getExn = getExn(_, modalRef)

    let rndSelect = (
        ~id:string, ~name:string, ~width:int, ~onChange:string=>unit, 
        ~options:array<(string,string)>, ~value:string,
        ~disabled:bool=false,
    ) => {
        <FormControl size=#small disabled>
            <InputLabel id>name</InputLabel>
            <Select
                sx={"width": width}
                labelId=id
                value=value
                label=name
                onChange=evt2str(onChange)
            >
                {
                    options->Array.map(((optionId,optionName)) => {
                        <MenuItem key=optionId value=optionId>{React.string(optionName)}</MenuItem>
                    })->React.array
                }
            </Select>
        </FormControl>
    }

    let getBkgColor: 'a. (option<'a>, 'a) => option<string> = (initValue, currValue) => {
        switch initValue {
            | None => None
            | Some(initValue) => {
                if (initValue == currValue) {
                    None
                } else {
                    Some("yellow")
                }
            }
        }
    }

    let areTagsChanged = () => {
        switch cardDto {
            | None => false
            | Some(cardDto) => {
                cardDto.tagIds->Belt_HashSetString.fromArray != state.cardDto.tagIds->Belt_HashSetString.fromArray
            }
        }
    }

    let rndTranslateCardData = (data:translateCardDto) => {
        let ( initNative, initForeign, initTran, initNfPaused, initFnPaused ) = switch cardDto {
            | None => (None,None,None,None,None,)
            | Some(cardDto) => {
                switch cardDto.data {
                    | Translate(initData) => {
                        (Some(initData.native),Some(initData.foreign),Some(initData.tran),
                            Some(initData.nfPaused),Some(initData.fnPaused),)
                    }
                }
            }
        }
        let { native, foreign, tran, nfPaused, fnPaused} = data
        <Col>
            <TextField 
                size=#small
                style=ReactDOM.Style.make(~width="300px", ~backgroundColor=?getBkgColor(initNative,native), ())
                label="Native" 
                value=native
                onChange=evt2str(str => setState(setNative(_,str)))
                autoFocus=true
                // onKeyDown=kbrdHnd2(
                //     kbrdClbkMake(~key=keyEnter, ~act=()=>onSave(state.tag)),
                //     kbrdClbkMake(~key=keyEsc, ~act=onCancel),
                // )
            />
            <TextField 
                size=#small
                style=ReactDOM.Style.make(~width="300px", ~backgroundColor=?getBkgColor(initForeign,foreign), ())
                label="Foreign" 
                value=foreign
                onChange=evt2str(str => setState(setForeign(_,str)))
                // onKeyDown=kbrdHnd2(
                //     kbrdClbkMake(~key=keyEnter, ~act=()=>onSave(state.tag)),
                //     kbrdClbkMake(~key=keyEsc, ~act=onCancel),
                // )
            />
            <TextField 
                size=#small
                style=ReactDOM.Style.make(~width="300px", ~backgroundColor=?getBkgColor(initTran,tran), ())
                label="Transcription" 
                value=tran
                onChange=evt2str(str => setState(setTran(_,str)))
                // onKeyDown=kbrdHnd2(
                //     kbrdClbkMake(~key=keyEnter, ~act=()=>onSave(state.tag)),
                //     kbrdClbkMake(~key=keyEsc, ~act=onCancel),
                // )
            />
            <FormControlLabel
                control={
                    <Checkbox
                        checked=nfPaused
                        onChange={evt2bool(checked => setState(setNfPaused(_,checked)))}
                    />
                }
                label="pause Native -> Foreign"
                style=ReactDOM.Style.make(~backgroundColor=?getBkgColor(initNfPaused,nfPaused), ())
            />
            <FormControlLabel
                control={
                    <Checkbox
                        checked=fnPaused
                        onChange={evt2bool(checked => setState(setFnPaused(_,checked)))}
                    />
                }
                label="pause Foreign -> Native"
                style=ReactDOM.Style.make(~backgroundColor=?getBkgColor(initFnPaused,fnPaused), ())
            />
        </Col>
    }

    let rndCardData = () => {
        switch state.cardDto.data {
            | Translate(data) => rndTranslateCardData(data)
        }
    }

    let actSave = async () => {
        switch cardDto {
            | None => {
                (await createCard(state.cardDto)->getExn)->ignore
                setState(st => {
                    switch state.cardDto.data {
                        | Translate(_) => {
                            let st = st->setNative("")
                            let st = st->setForeign("")
                            let st = st->setTran("")
                            st
                        }
                    }
                })
            }
            | Some(_) => {
                let cardDto = await updateCard(state.cardDto)->getExn
                onSaved->Option.forEach(onSaved => onSaved(cardDto))
            }
        }
    }

    let cardDataEq = (card1:cardData,card2:cardData):bool => {
        switch card1 {
            | Translate(card1) => {
                switch card2 {
                    | Translate(card2) => card1 == card2
                }
            }
        }
    }

    let isCardModified = () => {
        switch cardDto {
            | None => false
            | Some(cardDto) => {
                cardDto.isDeleted != state.cardDto.isDeleted
                || areTagsChanged()
                || !cardDataEq(cardDto.data, state.cardDto.data)
            }
        }
    }

    let rndButtons = () => {
        <Row>
            <Button 
                onClick=clickHnd(~act=() => actSave()->ignore) color="primary" variant=#contained
                disabled={!isCardModified()}
            >
                {React.string("Save")}
            </Button>
            {
                switch cardDto {
                    | None => React.null
                    | Some(_) => {
                        <Button 
                            onClick=clickHnd(~act=()=>onCancel->Option.forEach(onCancel=>onCancel())) 
                            color="primary" variant=#outlined
                        >
                            {React.string("Cancel")}
                        </Button>
                    }
                }
            }
        </Row>
    }

    <Col style=ReactDOM.Style.make(~padding="10px", ())>
        {rndSelect(
            ~id="Card type", ~name="Card type", ~width=200, 
            ~onChange=str=>setState(setCardType(_,str->strToCardType)), 
            ~options=[(Translate->cardTypeToStr,"Translate")], 
            ~value=state->getCurrCardType->cardTypeToStr,
            ~disabled=cardDto->Option.isSome,
        )}
        {rndCardData()}
        <TagSelector
            modalRef
            allTags
            initSelectedTagIds=state.cardDto.tagIds
            createTag
            getRemainingTags
            onChange = {tags => setState(setTagIds(_,tags))}
            bkgColor=?(areTagsChanged()?Some("yellow"):None)
        />
        {rndButtons()}
    </Col>
}
