

@module("@mui/material/MenuItem") @react.component
external make: (
    ~value:string=?,
    ~disabled:bool=?,
    ~onClick:unit=>unit=?,
    ~children:React.element=?
) => React.element = "default"