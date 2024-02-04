module Accordion = Expln_React_Accordion
module AccordionDetails = Expln_React_AccordionDetails
module AccordionSummary = Expln_React_AccordionSummary
module AppBar = Expln_React_AppBar
module Box = Expln_React_Box
module Button = Expln_React_Button
module ButtonGroup = Expln_React_ButtonGroup
module Checkbox = Expln_React_Checkbox
module Col = Expln_React_Column
module Dialog = Expln_React_Dialog
module Divider = Expln_React_Divider
module FormControl = Expln_React_FormControl
module FormControlLabel = Expln_React_FormControlLabel
module Grid = Expln_React_Grid
module IconButton = Expln_React_IconButton
module Input = Expln_React_Input
module InputAdornment = Expln_React_InputAdornment
module InputLabel = Expln_React_InputLabel
module List = Expln_React_List
module ListItem = Expln_React_ListItem
module ListItemButton = Expln_React_ListItemButton
module ListItemIcon = Expln_React_ListItemIcon
module ListItemText = Expln_React_ListItemText
module Menu = Expln_React_Menu
module MenuItem = Expln_React_MenuItem
module Pagination = Expln_React_Pagination
module Paper = Expln_React_Paper
module Row = Expln_React_Row
module Radio = Expln_React_Radio
module RadioGroup = Expln_React_RadioGroup
module Select = Expln_React_Select
module Slider = Expln_React_Slider
module Tab = Expln_React_Tab
module Tabs = Expln_React_Tabs
module TextField = Expln_React_TextField
module ThemeProvider = Expln_React_ThemeProvider
module TextFileReader = Expln_React_TextFileReader

external reElem2Obj: React.element => Js.Nullable.t<{..}> = "%identity"
let evt2str = (strConsumer:string=>unit):(ReactEvent.Form.t=>unit) => evt => strConsumer(ReactEvent.Form.target(evt)["value"])
let evt2bool = (boolConsumer:bool=>unit):(ReactEvent.Form.t=>unit) => evt => boolConsumer(ReactEvent.Form.target(evt)["checked"])

@val external navigator: {..} = "navigator"
@val external window: {..} = "window"

let getAvailWidth = ():int => {
    window["screen"]["availWidth"]
}

let copyToClipboard = (text:string):promise<unit> => {
    navigator["clipboard"]["writeText"](. text)
}

type mouseButton = Left | Middle | Right

type clickCallback = {
    btn:mouseButton,
    alt:bool,
    shift:bool,
    ctrl:bool,
    act:unit=>unit,
}

let mouseButtonToInt = (btn:mouseButton):int => {
    switch btn {
        | Left => 0
        | Middle => 1
        | Right => 2
    }
}

let clickClbkMake = (
    ~btn:mouseButton=Left,
    ~alt:bool=false,
    ~shift:bool=false,
    ~ctrl:bool=false,
    ~act:unit=>unit,
) => {
    { btn, alt, shift, ctrl, act, }
}

let clickHnd = (
    ~btn:mouseButton=Left,
    ~alt:bool=false,
    ~shift:bool=false,
    ~ctrl:bool=false,
    ~act:unit=>unit,
):(ReactEvent.Mouse.t => unit) => {
    evt => {
        if (
            evt->ReactEvent.Mouse.button === btn->mouseButtonToInt
            && evt->ReactEvent.Mouse.altKey === alt
            && evt->ReactEvent.Mouse.ctrlKey === ctrl
            && evt->ReactEvent.Mouse.shiftKey === shift
        ) {
            act()
        }
    }
}

let runClickCallback = (evt:ReactEvent.Mouse.t, clbk:clickCallback):unit => {
    if (
        evt->ReactEvent.Mouse.button === clbk.btn->mouseButtonToInt
        && evt->ReactEvent.Mouse.altKey === clbk.alt
        && evt->ReactEvent.Mouse.ctrlKey === clbk.ctrl
        && evt->ReactEvent.Mouse.shiftKey === clbk.shift
    ) {
        clbk.act()
    }
}

let clickHnd2 = ( clbk1:clickCallback, clbk2:clickCallback, ):(ReactEvent.Mouse.t => unit) => {
    evt => {
        runClickCallback(evt,clbk1)
        runClickCallback(evt,clbk2)
    }
}

let keyEnter = "Enter"
let keyEsc = "Escape"

type kbrdCallback = {
    key:string,
    alt:bool,
    shift:bool,
    ctrl:bool,
    act:unit=>unit,
}

let kbrdClbkMake = (
    ~key:string,
    ~alt:bool=false,
    ~shift:bool=false,
    ~ctrl:bool=false,
    ~act:unit=>unit,
) => {
    { key:key->Js_string2.toLowerCase, alt, shift, ctrl, act, }
}

let kbrdHnd = (
    ~key:string,
    ~alt:bool=false,
    ~shift:bool=false,
    ~ctrl:bool=false,
    ~act:unit=>unit,
):(ReactEvent.Keyboard.t => unit) => {
    let key = key->Js_string2.toLowerCase
    evt => {
        if (
            evt->ReactEvent.Keyboard.key->Js_string2.toLowerCase === key
            && evt->ReactEvent.Keyboard.altKey === alt
            && evt->ReactEvent.Keyboard.ctrlKey === ctrl
            && evt->ReactEvent.Keyboard.shiftKey === shift
        ) {
            act()
            evt->ReactEvent.Keyboard.stopPropagation
            evt->ReactEvent.Keyboard.preventDefault
        }
    }
}

let runKbrdCallback = (evt:ReactEvent.Keyboard.t, clbk:kbrdCallback):unit => {
    if (
        evt->ReactEvent.Keyboard.key->Js_string2.toLowerCase === clbk.key
        && evt->ReactEvent.Keyboard.altKey === clbk.alt
        && evt->ReactEvent.Keyboard.ctrlKey === clbk.ctrl
        && evt->ReactEvent.Keyboard.shiftKey === clbk.shift
    ) {
        clbk.act()
        evt->ReactEvent.Keyboard.stopPropagation
        evt->ReactEvent.Keyboard.preventDefault
    }
}

let kbrdHnd2 = ( clbk1:kbrdCallback, clbk2:kbrdCallback, ):(ReactEvent.Keyboard.t => unit) => {
    evt => {
        runKbrdCallback(evt,clbk1)
        runKbrdCallback(evt,clbk2)
    }
}

let kbrdHnd3 = ( clbk1:kbrdCallback, clbk2:kbrdCallback, clbk3:kbrdCallback, ):(ReactEvent.Keyboard.t => unit) => {
    evt => {
        runKbrdCallback(evt,clbk1)
        runKbrdCallback(evt,clbk2)
        runKbrdCallback(evt,clbk3)
    }
}

let kbrdHnds = ( clbks:array<kbrdCallback>):(ReactEvent.Keyboard.t => unit) => {
    evt => clbks->Js_array2.forEach(runKbrdCallback(evt,_))
}

