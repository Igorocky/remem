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

let makeInitialState = () => {
    {
        cardDto:makeInitialCardDto(Translate),
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

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
    ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
    ~getRemainingTags:array<Dtos.tagDto>=>promise<result<array<Dtos.tagDto>,string>>,
) => {
    let (state, setState) = React.useState(makeInitialState)

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

    let rndTranslateCardData = (data:translateCardDto) => {
        let { native, foreign, tran, } = data
        <Col>
            <TextField 
                size=#small
                style=ReactDOM.Style.make(~width="300px", ())
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
                style=ReactDOM.Style.make(~width="300px", ())
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
                style=ReactDOM.Style.make(~width="300px", ())
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
                        checked=data.nfPaused
                        onChange={evt2bool(checked => setState(setNfPaused(_,checked)))}
                    />
                }
                label="pause Native -> Foreign"
            />
            <FormControlLabel
                control={
                    <Checkbox
                        checked=data.fnPaused
                        onChange={evt2bool(checked => setState(setFnPaused(_,checked)))}
                    />
                }
                label="pause Foreign -> Native"
            />
            <TagSelector
                modalRef
                allTags
                initTagIds=state.cardDto.tagIds
                createTag
                getRemainingTags
                onChange = {tags => setState(setTagIds(_,tags))}
            />
        </Col>
    }

    let rndCardData = () => {
        switch state.cardDto.data {
            | Translate(data) => rndTranslateCardData(data)
        }
    }

    let actSave = async () => {
        (await createCard(state.cardDto)->getExn)->ignore
        setState(st => {
            switch state.cardDto.data {
                | Translate(cardData) => {
                    let st = st->setNative("")
                    let st = st->setForeign("")
                    let st = st->setTran("")
                    st
                }
            }
        })
    }

    let rndButtons = () => {
        <Row>
            <Button onClick=clickHnd(~act=() => actSave()->ignore) color="primary" variant=#contained>
                {React.string("Save")}
            </Button>
        </Row>
    }

    <Col style=ReactDOM.Style.make(~padding="10px", ())>
        {rndSelect(
            ~id="Card type", ~name="Card type", ~width=200, 
            ~onChange=str=>setState(setCardType(_,str->strToCardType)), 
            ~options=[(Translate->cardTypeToStr,"Translate")], 
            ~value=state->getCurrCardType->cardTypeToStr,
        )}
        {rndCardData()}
        {rndButtons()}
    </Col>
}
