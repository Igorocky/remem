@react.component
let make: (
    ~modalRef: Modal.modalRef, 
    ~allTags: array<Dtos.tagDto>,
    ~createTag:Dtos.tagDto=>unit,
) => React.element
