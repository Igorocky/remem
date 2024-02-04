external reElem2Obj: React.element => Js.Nullable.t<{..}> = "%identity"

let evt2str: (string=>unit) => (ReactEvent.Form.t=>unit)
let evt2bool: (bool=>unit) => (ReactEvent.Form.t=>unit)

let navigator: {..}
let window: {..}

let getAvailWidth: unit => int

let copyToClipboard: string => promise<unit>

type mouseButton = Left | Middle | Right

let clickHnd: (
    ~btn:mouseButton=?,
    ~alt:bool=?,
    ~shift:bool=?,
    ~ctrl:bool=?,
    ~act:unit=>unit,
) => (ReactEvent.Mouse.t => unit)

type clickCallback = {
    btn:mouseButton,
    alt:bool,
    shift:bool,
    ctrl:bool,
    act:unit=>unit,
}

let clickClbkMake: (~btn:mouseButton=?, ~alt:bool=?, ~shift:bool=?, ~ctrl:bool=?, ~act:unit=>unit) => clickCallback

let clickHnd2: ( clickCallback, clickCallback) => (ReactEvent.Mouse.t => unit)

let keyEnter: string
let keyEsc: string

let kbrdHnd: (
    ~key:string,
    ~alt:bool=?,
    ~shift:bool=?,
    ~ctrl:bool=?,
    ~act:unit=>unit,
) => (ReactEvent.Keyboard.t => unit)

type kbrdCallback = {
    key:string,
    alt:bool,
    shift:bool,
    ctrl:bool,
    act:unit=>unit,
}

let kbrdClbkMake: (~key:string, ~alt:bool=?, ~shift:bool=?, ~ctrl:bool=?, ~act:unit=>unit) => kbrdCallback

let kbrdHnd2: ( kbrdCallback, kbrdCallback) => (ReactEvent.Keyboard.t => unit)
let kbrdHnd3: ( kbrdCallback, kbrdCallback, kbrdCallback) => (ReactEvent.Keyboard.t => unit)
let kbrdHnds: array<kbrdCallback> => (ReactEvent.Keyboard.t => unit)

