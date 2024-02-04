

type position = [ #end | #start ]

@module("@mui/material/InputAdornment") @react.component
external make: (
    ~position:position=?,
    ~children:React.element=?
) => React.element = "default"