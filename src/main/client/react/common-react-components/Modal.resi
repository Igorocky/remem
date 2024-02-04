type modalId

type modalRef
let useModalRef: unit => modalRef

let openModal: (modalRef, unit => React.element) => promise<modalId>
let openModalFullScreen: (modalRef, unit => React.element) => promise<modalId>
let updateModal: (modalRef, modalId, unit => React.element) => unit
let closeModal: (modalRef, modalId) => unit

@react.component
let make: (~modalRef:modalRef) => React.element
