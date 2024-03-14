open Dtos

@react.component
let make: (
  ~modalRef: Modal.modalRef,
  ~allTags: array<Dtos.tagDto>,
  ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
  ~getRemainingTags:array<Dtos.tagDto>=>promise<result<array<Dtos.tagDto>,string>>,
  ~cardDto:cardDto=?,
  ~onSaved:cardDto=>unit=?,
  ~onCancel:unit=>unit=?,
) => React.element
