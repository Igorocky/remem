@react.component
let make: (
    ~modalRef: Modal.modalRef, 
    ~allTags: array<Dtos.tagDto>,
    ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
) => React.element
