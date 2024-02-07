type modalId

type modalRef
let useModalRef: unit => modalRef

let openModal: (modalRef, modalId => React.element) => unit
let closeModal: (modalRef, modalId) => unit

@react.component
let make: (~modalRef:modalRef) => React.element
