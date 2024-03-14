@react.component
let make: (
  ~modalRef: Modal.modalRef,
  ~allTags: array<Dtos.tagDto>,
  ~initTags: array<Dtos.tagDto> = ?,
  ~initTagIds: array<string> = ?,
  ~createTag: Dtos.tagDto => promise<result<Dtos.tagDto, string>>,
  ~getRemainingTags: array<Dtos.tagDto> => promise<result<array<Dtos.tagDto>, string>>,
  ~onChange: array<Dtos.tagDto> => unit,
  ~bkgColor:string=?,
) => React.element
