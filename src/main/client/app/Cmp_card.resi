open Dtos

@react.component
let make: (
  ~modalRef: Modal.modalRef,
  ~allTags: array<Dtos.tagDto>,
  ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
  ~getRemainingTagsSimple:array<tagDto>=>array<tagDto>,
  ~cardDto:cardDto=?,
  ~onSaved:cardDto=>unit=?,
  ~onCancel:unit=>unit=?,
) => React.element
