open Dtos

@react.component
let make: (
    ~modalRef:Modal.modalRef,
    ~allTags:array<tagDto>,
    ~initSelectedTags: array<tagDto> = ?,
    ~initSelectedTagIds: array<string> = ?,
    ~createTag:tagDto=>promise<result<tagDto,string>>,
    ~getRemainingTags:array<tagDto>=>promise<result<array<tagDto>,string>>,
    ~onChange: array<tagDto> => unit,
    ~bkgColor:string=?,
    ~resetSelectedTags:React.ref<Js.Nullable.t<array<tagDto>=>unit>>=?,
) => React.element
