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
}

let makeInitialState = (
    ~allTags:array<tagDto>, 
    ~initSelectedTags:option<array<tagDto>>, 
    ~initSelectedTagIds:option<array<string>>,
):state => {
    let selectedTags = initSelectedTags->Option.getOr(
        initSelectedTagIds
            ->Option.map(ids => allTags->Array.filter(tag => ids->Array.includes(tag.id)))
            ->Option.getOr([])
    )
    let selectedTagIds = selectedTags->Array.map(tag => tag.id)->Belt_HashSetString.fromArray
    {
        selectedTags,
        filterText: "",
        filteredTags: allTags,
        remainingTags: allTags->Array.filter(tag => !(selectedTagIds->Belt_HashSetString.has(tag.id))),
    }
}

let setSelectedTags = (st:state, selectedTags:array<tagDto>, remainingTags:array<tagDto>):state => {
    {
        selectedTags,
        filterText:"",
        filteredTags: remainingTags,
        remainingTags,
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

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<tagDto>,
    ~initSelectedTags: option<array<Dtos.tagDto>> = ?,
    ~initSelectedTagIds: option<array<string>> = ?,
    ~createTag:tagDto=>promise<result<tagDto,string>>,
    ~getRemainingTags:array<tagDto>=>promise<result<array<tagDto>,string>>,
    ~onChange: array<Dtos.tagDto> => unit,
    ~bkgColor:option<string>=?,
    ~resetSelectedTags:option<React.ref<Js.Nullable.t<array<tagDto>=>unit>>>=?,
) => {
    let (state, setState) = React.useState(() => makeInitialState(
        ~allTags, ~initSelectedTags, ~initSelectedTagIds
    ))

    let getExn = getExn(_, modalRef)

    let getOrderedSetOfTagIds = (tags:array<tagDto>):array<string> => {
        let res = tags->Array.map(tag => tag.id)
            ->Belt_HashSetString.fromArray
            ->Belt_HashSetString.toArray
        res->Array.sort(String.compare)
        res
    }

    let updateSelectedTags = async (update:array<tagDto>=>array<tagDto>) => {
        let newSelectedTags = state.selectedTags->update
        if (getOrderedSetOfTagIds(state.selectedTags) != getOrderedSetOfTagIds(newSelectedTags)) {
            let remainingTags = await getRemainingTags(newSelectedTags)->getExn
            setState(setSelectedTags(_,newSelectedTags,remainingTags))
        }
    }

    React.useEffect1(() => {
        let allTagIds = allTags->Array.map(tag => tag.id)->Belt_HashSetString.fromArray
        updateSelectedTags(selectedTags => 
            selectedTags->Array.filter(tag => allTagIds->Belt_HashSetString.has(tag.id))
        )->ignore
        None
    }, [allTags])

    React.useEffect1(() => {
        onChange(state.selectedTags)
        None
    }, [state.selectedTags])

    resetSelectedTags->Option.forEach(resetSelectedTags => {
        resetSelectedTags.current = Js.Nullable.return(newSelectedTags => {
            updateSelectedTags(_ => newSelectedTags)->ignore
        })
    })

    let actSelectTag = async tag => {
        updateSelectedTags(Array.concat(_, [tag]))
    }

    let actUnselectTag = async (tag:tagDto) => {
        updateSelectedTags(Array.filter(_, t => t.id != tag.id))
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

    <Paper style=ReactDOM.Style.make(~padding="5px", ~backgroundColor=?bkgColor, ())>
        <Col>
            {rndSelectedTags()}
            {rndFilter()}
            {rndFilteredTags()}
        </Col>
    </Paper>
}