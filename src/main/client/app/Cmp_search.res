open Mui_components
open Modal
open Common_utils
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
        },
        cards:None
    }
}

let setPageIdx = (st:state, pageIdx:int, cards:array<cardDto>):state => {
    {
        filter:{...st.filter, pageIdx},
        cards:Some(cards),
    }
}

let resetFilter = (st:state):state => {
    {
        filter:{...st.filter, pageIdx:0},
        cards:None,
    }
}

let findCards:beFunc<Dtos.FindCards.req, Dtos.FindCards.res> = createBeFunc(module(Dtos.FindCards))

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
    ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
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

    let rndFilter = () => {
        <Col>
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
            | Some(cards) => cards->Array.length < state.filter.itemsPerPage
        }
    }

    let rndPagination = () => {
        switch state.cards {
            | None => React.null
            | Some(_) => {
                <Row>
                    <Button onClick=clickHnd(~act=() => actSearch(0)->ignore) color="grey" variant=#contained
                        disabled={state.filter.pageIdx <= 0}
                    >
                        {React.string("<<")}
                    </Button>
                    <Button onClick=clickHnd(~act=() => actSearch(state.filter.pageIdx-1)->ignore) 
                        color="grey" variant=#contained
                        disabled={state.filter.pageIdx <= 0}
                    >
                        {React.string("<")}
                    </Button>
                    {(state.filter.pageIdx+1)->Int.toString->React.string}
                    <Button onClick=clickHnd(~act=() => actSearch(state.filter.pageIdx+1)->ignore) 
                        color="grey" variant=#contained
                        disabled={isLastPage()}
                    >
                        {React.string(">")}
                    </Button>
                </Row>
            }
        }
    }

    let rndSearchResult = () => {
        switch state.cards {
            | None => React.null
            | Some(cards) => {
                <Col>
                    {rndPagination()}
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
