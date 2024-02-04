

@module("./Dialog.js") @react.component
external make: (
    ~opn:bool=?,
    ~disableEscapeKeyDown:bool=?,
    ~fullScreen:bool=?,
    ~fullWidth:bool=?,
    ~maxWidth:string=?,
    ~onClose:unit=>unit=?,
    ~children: React.element,
) => React.element = "default"
