

type size = [ #small | #medium ]

@module("@mui/material/Input") @react.component
external make: (
    ~value:string=?,
    ~size:size=?,
    ~onChange:ReactEvent.Form.t=?,
) => React.element = "default"