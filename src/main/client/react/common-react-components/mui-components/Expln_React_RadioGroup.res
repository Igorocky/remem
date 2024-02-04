

@module("@mui/material/RadioGroup") @react.component
external make: (
    ~value:string=?,
    ~onChange:ReactEvent.Form.t=?,
    ~row:bool=?,
    ~children:React.element=?
) => React.element = "default"