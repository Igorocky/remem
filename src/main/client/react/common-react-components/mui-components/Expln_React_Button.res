

type variant = [#text|#contained|#outlined]
@module("@mui/material/Button") @react.component
external make: (
    ~onClick: ReactEvent.Mouse.t=>unit=?, 
    ~variant:variant=?, 
    ~disabled:bool=?,
    ~color:string=?,
    ~title:string=?,
    ~style:ReactDOMStyle.t=?,
    ~children: React.element=?
) => React.element = "default"
