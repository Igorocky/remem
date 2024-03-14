open Mui_components
open Modal
open Dtos
open BE_utils
open React_rnd_utils
open React_utils

type state = {
    filter:cardFilterDto,
    cards:option<array<cardDto>>,
}

let makeInitialState = ():state => {
    {
        filter: {
            itemsPerPage:5,
            pageIdx:0,
            deleted:false,
        },
        cards:None,
    }
}

let setPageIdx = (st:state, pageIdx:int, cards:array<cardDto>):state => {
    {
        ...st,
        filter:{...st.filter, pageIdx},
        cards:Some(cards),
    }
}

let updateCard = (st:state, cardId:string, update:cardDto=>cardDto):state => {
    {
        ...st,
        cards:st.cards->Option.map(cards => cards->Array.map(card => card.id == cardId ? update(card) : card)),
    }
}

let setDeleted = (st:state, deleted:bool):state => {
    {
        ...st,
        filter:{...st.filter, deleted},
    }
}

let resetFilter = (st:state):state => {
    {
        filter:makeInitialState().filter,
        cards:None,
    }
}

let findCards:beFunc<Dtos.FindCards.req, Dtos.FindCards.res> = createBeFunc(module(Dtos.FindCards))
let deleteCard:beFunc<Dtos.DeleteCard.req, Dtos.DeleteCard.res> = createBeFunc(module(Dtos.DeleteCard))
let restoreCard:beFunc<Dtos.RestoreCard.req, Dtos.RestoreCard.res> = createBeFunc(module(Dtos.RestoreCard))

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
    ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
    ~getRemainingTags:array<Dtos.tagDto>=>promise<result<array<Dtos.tagDto>,string>>,
) => {
    let (state, setState) = React.useState(makeInitialState)

    let getExn = getExn(_, modalRef)

    let actSearch = async (pageIdx:int):unit => {
        let foundCards = await findCards({...state.filter, pageIdx})->getExn
        setState(setPageIdx(_,pageIdx,foundCards))
    }

    let actResetFilter = () => {
        setState(resetFilter)
    }

    let actToggleIsDeletedForCard = async (card:cardDto) => {
        let updatedCard = card.isDeleted 
            ? await restoreCard({cardId:card.id})->getExn 
            : await deleteCard({cardId:card.id})->getExn
        setState(updateCard(_,card.id,_=>updatedCard))
    }

    let actEdit = (cardDto:cardDto) => {
        openModal(modalRef, modalId => {
            <Paper style=ReactDOM.Style.make(~padding="10px", ())>
                <Cmp_card 
                    modalRef 
                    allTags 
                    createTag
                    getRemainingTags
                    cardDto=cardDto
                    onSaved={updatedCard => {
                        setState(updateCard(_,cardDto.id,_=>updatedCard))
                        closeModal(modalRef, modalId)
                    }}
                    onCancel={() => closeModal(modalRef, modalId)}
                />
            </Paper>
        })
    }

    let rndFilter = () => {
        <Col>
            <FormControlLabel
                control={
                    <Checkbox
                        checked={state.filter.deleted->Option.getOr(false)}
                        onChange={evt2bool(checked => setState(setDeleted(_,checked)))}
                    />
                }
                label="Deleted"
            />
            <Row>
                <Button onClick=clickHnd(~act=() => actSearch(0)->ignore) color="primary" variant=#contained>
                    {React.string("Search")}
                </Button>
                <Button onClick=clickHnd(~act=actResetFilter) color="primary" variant=#outlined>
                    {React.string("Reset search")}
                </Button>
            </Row>
        </Col>
    }

    let isLastPage = () => {
        switch state.cards {
            | None => true
            | Some(cards) => {
                state.filter.itemsPerPage->Option.mapOr(false, itemsPerPage => cards->Array.length < itemsPerPage)
            }
        }
    }

    let rndPagination = () => {
        switch state.cards {
            | None => React.null
            | Some(_) => {
                <Row>
                    <Button onClick=clickHnd(~act=() => actSearch(0)->ignore) color="grey" variant=#contained
                        disabled={state.filter.pageIdx->Option.mapOr(false, pageIdx => pageIdx <= 0)}
                    >
                        {React.string("<<")}
                    </Button>
                    <Button onClick=clickHnd(~act=() => actSearch(state.filter.pageIdx->Option.getOr(0)-1)->ignore) 
                        color="grey" variant=#contained
                        disabled={state.filter.pageIdx->Option.mapOr(false, pageIdx => pageIdx <= 0)}
                    >
                        {React.string("<")}
                    </Button>
                    {(state.filter.pageIdx->Option.getOr(0)+1)->Int.toString->React.string}
                    <Button onClick=clickHnd(~act=() => actSearch(state.filter.pageIdx->Option.getOr(0)+1)->ignore) 
                        color="grey" variant=#contained
                        disabled={isLastPage()}
                    >
                        {React.string(">")}
                    </Button>
                </Row>
            }
        }
    }

    let rndCard = (card:cardDto) => {
        switch card.data {
            | Translate(data) => {
                <Paper key=card.id>
                    {`Translate: ${data.foreign}`->React.string}
                </Paper>
            }
        }
    }

    let rndSearchResult = () => {
        switch state.cards {
            | None => React.null
            | Some(cards) => {
                <Col>
                    {rndPagination()}
                    <table>
                        <tbody>
                            {
                                cards->Array.map(card => {
                                    <tr key=card.id>
                                        <td>
                                            {
                                                rndSmallTextBtn(
                                                    ~text="edit", ~color="lightgrey", ~onClick=()=>actEdit(card)
                                                )
                                            }
                                        </td>
                                        <td>
                                            {
                                                rndSmallTextBtn(
                                                    ~text=card.isDeleted ? "restore" : "delete", 
                                                    ~color="lightgrey", 
                                                    ~onClick=()=>actToggleIsDeletedForCard(card)->ignore
                                                )
                                            }
                                        </td>
                                        <td>{rndCard(card)}</td>
                                    </tr>
                                })->React.array
                            }
                        </tbody>
                    </table>
                    {rndPagination()}
                </Col>
            }
        }
    }

    <Col style=ReactDOM.Style.make(~margin="10px", ())>
        {rndFilter()}
        {rndSearchResult()}
    </Col>

    // <Col>
    //     <TagSelector
    //         modalRef
    //         allTags
    //         createTag
    //         getRemainingTags = {selectedTags => {
    //             let selectedIds = selectedTags->Array.map(tag => tag.id)->Belt.HashSet.String.fromArray
    //             Promise.resolve(
    //                 allTags->Array.filter(tag => !(selectedIds->Belt.HashSet.String.has(tag.id)))->Ok
    //             )
    //         }}
    //         onChange = {_ => ()}
    //     />
    //     <TimeRangeSelector
    //         label="Created when"
    //         onChange = {range => {
    //             let (left,right) = parseTimeRange(range, Date.now())
    //             Console.log("---------------------------")
    //             switch left {
    //                 | None => Console.log("After: none")
    //                 | Some(left) => Console.log2("After:", Date.fromTime(left))
    //             }
    //             switch right {
    //                 | None => Console.log("Before: none")
    //                 | Some(right) => Console.log2("Before:", Date.fromTime(right))
    //             }
    //         }}
    //     />
    // </Col>
}
