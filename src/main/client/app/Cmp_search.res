open Mui_components
open React_utils
open BE_utils
open React_rnd_utils
open Modal

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
    ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
) => {
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
    />
}
