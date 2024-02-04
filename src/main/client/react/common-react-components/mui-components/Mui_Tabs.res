

type variant = [ #scrollable | #fullWidth | #standard ]

@module("@mui/material/Tabs") @react.component
external make: (
    ~value:string=?,
    ~onChange:(ReactEvent.Mouse.t=>unit,string)=>unit=?,
    ~variant:variant=?,
    ~style:ReactDOMStyle.t=?,
    ~children: React.element,
) => React.element = "default"
