open Mui_components
open BE_utils
open React_rnd_utils
open Modal
open Dtos

let mainTheme = ThemeProvider.createTheme(
    {
        "palette": {
            "white": { "main": "#ffffff", },
            "grey": { "main": "#e0e0e0", },
            "lightgrey": { "main": "#e2e2e2", },
            "red": { "main": "#FF0000", },
            "pastelred": { "main": "#FAA0A0", },
            "orange": { "main": "#FF7900", },
            "yellow": { "main": "#FFE143", }
        }
    }
)

type tabData =
    | Tags
    | Search
    | MakeCard

type state = {
    allTags:option<array<tagDto>>
}

let makeState = ():state => {
    {
        allTags: None
    }
}

let getAllTags:beFunc<GetAllTags.req, GetAllTags.res> = createBeFunc(module(GetAllTags))
let createTag = createBeFunc(module(CreateTag))
let updateTag = createBeFunc(module(UpdateTag))
let deleteTags = createBeFunc(module(DeleteTags))
let getRemainingTags = createBeFunc(module(GetRemainingTags))

let getRemainingTagsSimple = (allTags:array<tagDto>, selectedTags:array<tagDto>):array<tagDto> => {
    let selectedIds = selectedTags->Array.map(tag => tag.id)->Belt.HashSet.String.fromArray
    allTags->Array.filter(tag => !(selectedIds->Belt.HashSet.String.has(tag.id)))
}

@react.component
let make = () => {
    let modalRef = useModalRef()
    let {tabs, renderTabs, updateTabs, activeTabId} = UseTabs.useTabs()

    let (state, setState) = React.useState(makeState)

    let getExn = getExn(_, modalRef)

    React.useEffect0(()=>{
        updateTabs(st => {
            if (st->UseTabs.getTabs->Array.length == 0) {
                let (st, _) = st->UseTabs.addTab(~label="Tags", ~closable=false, ~data=Tags)
                let (st, _) = st->UseTabs.addTab(~label="Search", ~closable=false, ~data=Search, ~doOpen=true)
                let (st, _) = st->UseTabs.addTab(~label="Add card", ~closable=false, ~data=MakeCard)
                st
            } else {
                st
            }
        })
        getAllTags()->getExn->Promise.thenResolve(res => setState(_ => {allTags:Some(res.tags)}))->ignore
        None
    })

    let actCreateTag = async (tag:tagDto):result<tagDto,string> => {
        let res:CreateTag.res = await createTag({name:tag.name})->getExn
        setState(_ => {allTags:Some(res.tags)})
        switch res.tags->Array.find(t => t.name == tag.name) {
            | None => Error("Internal error: cannot identify the newly created tag.")
            | Some(tag) => Ok(tag)
        }
    }

    let actUpdateTag = async (tag:tagDto):unit => {
        let res:UpdateTag.res = await updateTag(tag)->getExn
        setState(_ => {allTags:Some(res.tags)})
    }

    let actDeleteTag = async (tag:tagDto):unit => {
        let res:DeleteTags.res = await deleteTags({ids:[tag.id]})->getExn
        setState(_ => {allTags:Some(res.tags)})
    }

    let rndTabContent = (tab:UseTabs.tab<'a>, allTags:array<tagDto>) => {
        <div key=tab.id style=ReactDOM.Style.make(~display=if (tab.id == activeTabId) {"block"} else {"none"}, ())>
            {
                switch tab.data {
                    | Tags => {
                        <Cmp_tag_list 
                            modalRef 
                            allTags 
                            createTag = {tag => actCreateTag(tag)->ignore}
                            updateTag = {tag => actUpdateTag(tag)->ignore}
                            deleteTag = {tag => actDeleteTag(tag)->ignore}
                        />
                    }
                    | Search => {
                        <Cmp_search 
                            modalRef 
                            allTags 
                            createTag=actCreateTag
                            getRemainingTags={(deleted,selectedTags) => {
                                getRemainingTags(
                                    { 
                                        Dtos.GetRemainingTags.selectedTagIds:selectedTags->Array.map(tag => tag.id),
                                        deleted,

                                    }
                                )
                            }}
                            getRemainingTagsSimple=getRemainingTagsSimple(allTags,_)
                        />
                    }
                    | MakeCard => {
                        <Cmp_card 
                            modalRef 
                            allTags 
                            createTag=actCreateTag
                            getRemainingTagsSimple=getRemainingTagsSimple(allTags,_)
                        />
                    }
                }
            }
        </div>
    }

    switch state.allTags {
        | None => "Loading..."->React.string
        | Some(allTags) => {
            <ThemeProvider theme=mainTheme>
                <ContentWithStickyHeader
                    top=0
                    header=renderTabs()
                    content={_ => {
                        <Col>
                            {React.array(tabs->Js_array2.map(rndTabContent(_, allTags)))}
                            <Modal modalRef />
                        </Col>
                    }}
                />
            </ThemeProvider>
        }
    }
}
