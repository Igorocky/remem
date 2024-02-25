open Mui_components
open Modal
open Common_utils

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
    ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
) => {
    <Col>
        <TagSelector
            modalRef
            allTags
            createTag
            getRemainingTags = {selectedTags => {
                let selectedIds = selectedTags->Array.map(tag => tag.id)->Belt.HashSet.String.fromArray
                Promise.resolve(
                    allTags->Array.filter(tag => !(selectedIds->Belt.HashSet.String.has(tag.id)))->Ok
                )
            }}
            onChange = {_ => ()}
        />
        <TimeRangeSelector
            label="Created when"
            onChange = {range => {
                let (left,right) = parseTimeRange(range, Date.now())
                Console.log("---------------------------")
                switch left {
                    | None => Console.log("After: none")
                    | Some(left) => Console.log2("After:", Date.fromTime(left))
                }
                switch right {
                    | None => Console.log("Before: none")
                    | Some(right) => Console.log2("Before:", Date.fromTime(right))
                }
            }}
        />
    </Col>
}
