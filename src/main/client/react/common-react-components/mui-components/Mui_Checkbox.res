

@module("@mui/material/Checkbox") @react.component
external make: (
    ~style: ReactDOMStyle.t=?,
    ~disabled: bool=?,
    ~indeterminate: bool=?,
    ~checked: bool=?,
    ~onChange: ReactEvent.Form.t=?,
) => React.element = "default"
