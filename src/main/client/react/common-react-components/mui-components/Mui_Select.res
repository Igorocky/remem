

@module("@mui/material/Select") @react.component
external make: (
    ~sx:{..}=?,
    ~labelId:string=?,
    ~label:string=?,
    ~value:string,
    ~onChange:ReactEvent.Form.t=>unit=?,
    ~onClose:unit=>unit=?,
    ~children:React.element=?
) => React.element = "default"