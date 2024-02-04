

@module("@mui/material/FormControlLabel") @react.component
external make: (
    ~control: React.element,
    ~label: string, 
    ~disabled: bool=?, 
    ~style: ReactDOMStyle.t=?,
    ~value: string=?,
) => React.element = "default"
