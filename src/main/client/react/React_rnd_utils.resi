open Modal

let nbsp:string

let rndHiddenTextField: (~key: string=?, ~onKeyDown: ReactEvent.Keyboard.t => unit) => React.element

let openYesNoDialog: (
  ~modalRef: Modal.modalRef,
  ~title: string=?,
  ~icon: React.element=?,
  ~text: string=?,
  ~content: React.element=?,
  ~textYes: string=?,
  ~textNo: string=?,
) => promise<bool>

let rndSmallTextBtn: (~text: string, ~color: string=?, ~onClick: unit => unit) => React.element

let rndColorSelect: (
  ~availableColors: array<string>,
  ~selectedColor: string,
  ~onNewColorSelected: string => unit,
  ~label: string=?,
) => React.element

let getExn: (promise<result<'a,string>>, modalRef) => promise<'a>