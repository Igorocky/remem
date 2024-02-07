@react.component
let make: (
  ~tag: Dtos.tagDto=?,
  ~onSave: Dtos.tagDto => unit,
  ~onCancel: unit => unit,
) => React.element
