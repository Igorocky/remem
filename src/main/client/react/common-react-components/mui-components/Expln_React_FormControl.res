

type size = [#small | #medium]

@module("@mui/material/FormControl") @react.component
external make: (
    ~disabled:bool=?,
    ~size:size=?,
    ~style:ReactDOMStyle.t=?,
    ~children:React.element=?
) => React.element = "default"