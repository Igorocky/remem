@react.component
let make: (
    ~modalRef: Modal.modalRef, 
    ~allTags: array<Dtos.tagDto>,
    ~createTag:Dtos.tagDto=>unit,
    ~updateTag:Dtos.tagDto=>unit,
    ~deleteTag:Dtos.tagDto=>unit,
) => React.element
