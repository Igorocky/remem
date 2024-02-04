

type variant = [#text|#contained|#outlined]
@module("@mui/material/IconButton") @react.component
external make: (
    ~ref:ReactDOM.domRef=?,
    ~onClick: ReactEvent.Mouse.t=>unit=?, 
    ~color: string=?, 
    ~style: ReactDOMStyle.t=?,
    ~component:string=?,
    ~disabled:bool=?,
    ~title:string=?,
    ~children: React.element=?
) => React.element = "default"
