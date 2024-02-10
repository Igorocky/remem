open Mui_components
open React_utils
open BE_utils
open React_rnd_utils
open Modal
open Common_utils

type state = {
    selectedTags: array<Dtos.tagDto>,
    filterText:string,
    filteredTags: array<Dtos.tagDto>,
    remainingTags: array<Dtos.tagDto>,
    reqCnt:int,
}

let makeInitialState = (~allTags:array<Dtos.tagDto>,) => {
    {
        selectedTags: [],
        filterText: "",
        filteredTags: allTags,
        remainingTags: allTags,
        reqCnt: 0,
    }
}

let selectTag = (st:state,tag:Dtos.tagDto):state => {
    let newSelectedTags = Array.concat(st.selectedTags, [tag])
    newSelectedTags->Array.sort(comparatorByStr((tag:Dtos.tagDto) => tag.name))
    let newRemainingTags = st.remainingTags->Array.filter(t => t.id != tag.id)
    {
        ...st,
        selectedTags: newSelectedTags,
        filterText:"",
        filteredTags: newRemainingTags,
        remainingTags: newRemainingTags,
    }
}

let unselectTag = (st:state,tag):state => {
    let newRemainingTags = Array.concat(st.remainingTags, [tag])
    newRemainingTags->Array.sort(comparatorByStr((tag:Dtos.tagDto) => tag.name))
    {
        ...st,
        selectedTags: st.selectedTags->Array.filter(t => t.id != tag.id),
        filterText:"",
        filteredTags: newRemainingTags,
        remainingTags: newRemainingTags,
    }
}

let setFilterText = (st:state,text:string):state => {
    let textTrimed = text->String.trim->String.toLowerCase
    {
        ...st,
        filterText:text,
        filteredTags: st.remainingTags->Array.filter(tag => tag.name->String.toLowerCase->String.includes(textTrimed))
    }
}

let setRemainingTags = (st:state,tags):state => {
    {
        ...st,
        remainingTags:tags,
    }->setFilterText(st.filterText)
}

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
    // ~createTag:Dtos.tagDto=>unit,
    // ~getRemainingTags:array<Dtos.tagDto>=>promise<array<Dtos.tagDto>>,
) => {
    let (state, setState) = React.useState(() => makeInitialState(~allTags))

    // let actUnselectTag = () => {

    // }

    let rndSelectedTags = () => {
        <Row>
            {
                state.selectedTags->Array.map(tag => {
                    <span key=tag.id>
                        <span>{tag.name->React.string}</span>
                        <span onClick=clickHnd(~act=()=>())>{"X"->React.string}</span>
                    </span>
                })->React.array
            }
        </Row>
    }

    <Col>
        {rndSelectedTags()}
    </Col>
}
