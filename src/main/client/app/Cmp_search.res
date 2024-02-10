open Mui_components
open React_utils
open BE_utils
open React_rnd_utils
open Modal

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
) => {
    // "Cmp_search"->React.string
    <TagSelector
        modalRef
        allTags
    />
}
