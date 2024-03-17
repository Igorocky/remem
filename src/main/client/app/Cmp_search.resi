open Dtos

@react.component
let make: (
    ~modalRef: Modal.modalRef, 
    ~allTags: array<tagDto>,
    ~createTag: tagDto => promise<result<tagDto, string>>,
    ~getRemainingTags:(bool,array<tagDto>)=>promise<result<array<tagDto>,string>>,
    ~getRemainingTagsSimple:array<tagDto>=>array<tagDto>,
) => React.element
