

@module("./Menu.js") @react.component
external make: (
    ~opn:bool=?,
    ~anchorEl:Dom.element=?,
    ~onClose:unit=>unit=?,
    ~children:React.element=?
) => React.element = "default"