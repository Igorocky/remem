

type size = [ #medium | #small ]
type variant = [ #filled | #outlined | #standard ]

@module("@mui/material/TextField") @react.component
external make: (
    ~inputRef:ReactDOM.domRef=?,
    ~value:string=?,
    ~label:string=?,
    ~size:size=?,
    ~style:ReactDOMStyle.t=?,
    ~variant:variant=?,
    ~multiline:bool=?,
    ~minRows:int=?,
    ~maxRows:int=?,
    ~rows:int=?,
    ~onChange:ReactEvent.Form.t=?,
    ~onKeyDown:ReactEvent.Keyboard.t=?,
    ~onKeyUp:ReactEvent.Keyboard.t=?,
    ~inputProps:{..}=?,
    ~disabled:bool=?,
    ~autoFocus:bool=?,
    ~autoComplete:string=?,
    ~title:string=?,
    ~error:bool=?,
) => React.element = "default"