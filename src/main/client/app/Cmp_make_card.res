open Mui_components
open React_utils
open BE_utils
open React_rnd_utils
open Modal
open Dtos

type state = {
    cardType:cardType,
    cardData:cardData,
}

let makeInitialCardData = (cardType:cardType) => {
    switch cardType {
        | Translate => {
            Translate({
                native:"",
                foreign:"",
                tran:"",
                tagIds:[],
            })
        }
    }
}

let makeInitialState = () => {
    {
        cardType:Translate,
        cardData:makeInitialCardData(Translate),
    }
}

let setCardType = (st:state, newCardType:cardType):state => {
    if (st.cardType == newCardType) {
        st
    } else {
        {
            cardType:newCardType,
            cardData:makeInitialCardData(newCardType),
        }
    }
}

let updateTranslateCardData = (st:state, upd:Dtos.CreateTranslateCard.req=>Dtos.CreateTranslateCard.req):state => {
    switch st.cardData {
        | Translate(data) => { ...st, cardData: Translate(data->upd) }
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
    updateTranslateCardData(st, data => {...data, tagIds:tags->Array.map(tag => tag.id)})
}

let createTranslateCard:beFunc<Dtos.CreateTranslateCard.req, Dtos.CreateTranslateCard.res> = 
    createBeFunc(module(Dtos.CreateTranslateCard))

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

    let rndTranslateCardData = (data:Dtos.CreateTranslateCard.req) => {
        let { native, foreign, tran, tagIds, } = data
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
            <TagSelector
                modalRef
                allTags
                createTag
                getRemainingTags
                onChange = {tags => setState(setTagIds(_,tags))}
            />
        </Col>
    }

    let rndCardData = () => {
        switch state.cardData {
            | Translate(data) => rndTranslateCardData(data)
        }
    }

    let actSave = async () => {
        switch state.cardData {
            | Translate(data) => {
                await createTranslateCard(data)->getExn
                setState(st => {
                    let st = st->setNative("")
                    let st = st->setForeign("")
                    let st = st->setTran("")
                    st
                })
            }
        }
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
            ~value=state.cardType->cardTypeToStr,
        )}
        {rndCardData()}
        {rndButtons()}
    </Col>
}
