open Mui_components
open React_utils
open React_rnd_utils
open Modal
open Common_utils

type tagDto = Dtos.tagDto

type state = {
    selectedTags: array<tagDto>,
    filterText:string,
    filteredTags: array<tagDto>,
    remainingTags: array<tagDto>,
    reqCnt:int,
}

let makeInitialState = (~allTags:array<tagDto>, ~initTags:array<tagDto>, ~initTagIds:array<string>,) => {
    let selectedTags = if (initTagIds->Array.length > initTags->Array.length) {
        allTags->Array.filter(tag => initTagIds->Array.includes(tag.id))
    } else {
        initTags
    }
    {
        selectedTags,
        filterText: "",
        filteredTags: allTags,
        remainingTags: allTags,
        reqCnt: 0,
    }
}

let selectTag = (st:state, tag:tagDto, remaininTags:array<tagDto>):state => {
    {
        ...st,
        selectedTags: 
            Array.concat(st.selectedTags, [tag])
            ->Array.toSorted(comparatorByStr((tag:tagDto) => tag.name)),
        filterText:"",
        filteredTags: remaininTags,
        remainingTags: remaininTags,
    }
}

let unselectTag = (st:state, tag:tagDto, remaininTags:array<tagDto>):state => {
    {
        ...st,
        selectedTags: st.selectedTags->Array.filter(t => t.id != tag.id),
        filterText:"",
        filteredTags: remaininTags,
        remainingTags: remaininTags,
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

let setRemainingTags = (st:state, remaininTags:array<tagDto>):state => {
    {
        ...st,
        remainingTags: remaininTags,
    }->setFilterText(st.filterText)
}

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<tagDto>,
    ~initTags: array<Dtos.tagDto> = [],
    ~initTagIds: array<string> = [],
    ~createTag:tagDto=>promise<result<tagDto,string>>,
    ~getRemainingTags:array<tagDto>=>promise<result<array<tagDto>,string>>,
    ~onChange: array<Dtos.tagDto> => unit,
) => {
    let (state, setState) = React.useState(() => makeInitialState(~allTags, ~initTags, ~initTagIds))

    let getExn = getExn(_, modalRef)

    let actUpdateRemainingTags = async () => {
        let remainingTags = await getRemainingTags(state.selectedTags)->getExn
        setState(setRemainingTags(_,remainingTags))
    }

    React.useEffect1(() => {
        actUpdateRemainingTags()->ignore
        None
    }, [allTags])

    React.useEffect1(() => {
        onChange(state.selectedTags)
        None
    }, [state.selectedTags])

    let actSelectTag = async tag => {
        let selectedTags = state.selectedTags->Array.concat([tag])
        let remainingTags = await getRemainingTags(selectedTags)->getExn
        setState(selectTag(_,tag,remainingTags))
    }

    let actUnselectTag = async (tag:tagDto) => {
        let selectedTags = state.selectedTags->Array.filter(t => t.id != tag.id)
        let remainingTags = await getRemainingTags(selectedTags)->getExn
        setState(unselectTag(_, tag, remainingTags))
    }

    let actCreateNewTagOrSelectSingleFilteredTag = async () => {
        if (state.filteredTags->Array.length == 1) {
            actSelectTag(state.filteredTags->Array.getUnsafe(0))->ignore
        } else {
            let newTagName = state.filterText->String.trim
            let newTagConfirmed = await openYesNoDialog(
                ~modalRef,
                ~text=`Create a new tag '${newTagName}'?`,
                ~textYes="Create",
                ~textNo="Cancel",
            )
            if (newTagConfirmed) {
                let newTag = await createTag({id:"", name:newTagName})->getExn
                actSelectTag(newTag)->ignore
            }
        }
    }

    let rndSelectedTags = () => {
        <Row>
            {
                state.selectedTags->Array.map(tag => {
                    <span key=tag.id>
                        <span>{tag.name->React.string}</span>
                        <span onClick=clickHnd(~act=()=>actUnselectTag(tag)->ignore)>{"[X]"->React.string}</span>
                    </span>
                })->React.array
            }
        </Row>
    }

    let rndFilter = () => {
        <TextField
            size=#small
            style=ReactDOM.Style.make(~width="300px", ())
            label="Tag" 
            value=state.filterText
            onChange=evt2str(newText => setState(setFilterText(_,newText)))
            // autoFocus=true
            onKeyDown=kbrdHnd2(
                kbrdClbkMake(~key=keyEnter, ~act=()=>actCreateNewTagOrSelectSingleFilteredTag()->ignore),
                kbrdClbkMake(~key=keyEsc, ~act=()=>setState(setFilterText(_,""))),
            )
        />
    }

    let rndFilteredTags = () => {
        <Row>
            {
                state.filteredTags->Array.map(tag => {
                    <span key=tag.id onClick=clickHnd(~act=()=>actSelectTag(tag)->ignore)>{tag.name->React.string}</span>
                })->React.array
            }
        </Row>
    }

    <Paper style=ReactDOM.Style.make(~padding="5px", ())>
        <Col>
            {rndSelectedTags()}
            {rndFilter()}
            {rndFilteredTags()}
        </Col>
    </Paper>
}
