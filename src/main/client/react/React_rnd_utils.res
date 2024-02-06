open React_utils
open Mui_components
open Modal

let rndHiddenTextField = (~key:option<string>=?, ~onKeyDown:ReactEvent.Keyboard.t=>unit):React.element => {
    <TextField 
        key=?key
        size=#small
        style=ReactDOM.Style.make(~width="0px", ~height="0px", ~opacity="0", ())
        onKeyDown
        autoFocus=true
        autoComplete="off"
    />
}

let rndDialogContent = (
    ~text:option<string>, 
    ~content:option<React.element>, 
) => {
    switch content {
        | Some(content) => content
        | None => text->Belt_Option.getWithDefault("")->React.string
    }
}

let rndYesNoDialog = (
    ~title:option<string>, 
    ~icon:option<React.element>,
    ~text:option<string>, 
    ~content:option<React.element>, 
    ~textYes:option<string>, 
    ~onYes:option<unit=>unit>, 
    ~textNo:option<string>, 
    ~onNo:option<unit=>unit>, 
) => {
    <Paper style=ReactDOM.Style.make(~padding="10px", ())>
        <Col spacing=1.>
            <span 
                style=ReactDOM.Style.make(
                    ~fontWeight="bold", 
                    ~display=?{if (title->Belt_Option.isNone) {Some("none")} else {None}}, 
                    ()
                )
            >
                {title->Belt_Option.getWithDefault("")->React.string}
            </span>
            {
                switch icon {
                    | None => {
                        <span>
                            {rndDialogContent(~text, ~content)}
                        </span>
                    }
                    | Some(icon) => {
                        <table>
                            <tbody>
                                <tr>
                                    <td>
                                        icon
                                    </td>
                                    <td style=ReactDOM.Style.make(~paddingLeft="5px", () )>
                                        {rndDialogContent(~text, ~content)}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    }
                }
            }
            <Row>
                {
                    textYes->Option.flatMap(textYes => onYes->Option.map(onYes => {
                        <Button onClick={_=>onYes()} variant=#outlined >
                            {React.string(textYes)}
                        </Button>
                    }))->Option.getOr(React.null)
                }
                {
                    textNo->Option.flatMap(textNo => onNo->Option.map(onNo => {
                        <Button onClick={_=>onNo()} variant=#outlined >
                            {React.string(textNo)}
                        </Button>
                    }))->Option.getOr(React.null)
                }
                {
                    rndHiddenTextField(
                        ~onKeyDown=kbrdHnd2(
                            kbrdClbkMake(~key=keyEnter, ~act=()=>onYes->Option.forEach(onYes => onYes())),
                            kbrdClbkMake(~key=keyEsc, ~act=()=>onNo->Option.forEach(onNo => onNo())),
                        ),
                    )
                }
            </Row>
        </Col>
    </Paper>
}

let openYesNoDialog = async (
    ~modalRef:modalRef, 
    ~title:option<string>=?, 
    ~icon:option<React.element>=?,
    ~text:option<string>=?, 
    ~content:option<React.element>=?, 
    ~textYes:option<string>=?, 
    ~textNo:option<string>=?, 
):bool => {
    let modalId = await openModal(modalRef, _ => React.null)
    await Promise.make((rlv,_) => {
        updateModal(modalRef, modalId, () => {
            rndYesNoDialog(
                ~title,
                ~icon,
                ~text, 
                ~content, 
                ~textYes,
                ~onYes = textYes->Option.map(_ => {
                    () => {
                        closeModal(modalRef, modalId)
                        rlv(true)
                    }
                }),
                ~textNo,
                ~onNo = textNo->Option.map(_ => {
                    () => {
                        closeModal(modalRef, modalId)
                        rlv(false)
                    }
                }),
            )
        })
    })
}

let rndSmallTextBtn = (~text:string, ~color:string="grey", ~onClick:unit=>unit):React.element => {
    <span
        onClick={_=> onClick() }
        style=ReactDOM.Style.make( 
            ~cursor="pointer", 
            ~color, 
            ~fontSize="0.7em", 
            ~padding="2px",
            ~borderRadius="3px",
            ()
        )
        className="grey-bkg-on-hover"
    >
        {React.string(text)}
    </span>
}

let rndColorSelect = (
    ~availableColors:array<string>, 
    ~selectedColor:string, 
    ~onNewColorSelected:string=>unit,
    ~label:option<string>=?,
):React.element => {
    <FormControl size=#small >
        {
            switch label {
                | Some(label) => <InputLabel id="label-for-color-select">label</InputLabel>
                | None => React.null
            }
        }
        <Select 
            labelId="label-for-color-select"
            ?label
            value=selectedColor
            onChange=evt2str(onNewColorSelected)
        >
            {
                React.array(availableColors->Array.map(color => {
                    <MenuItem key=color value=color>
                        <div style=ReactDOM.Style.make(~width="50px", ~height="20px", ~backgroundColor=color, ()) />
                    </MenuItem>
                }))
            }
        </Select>
    </FormControl>
}

let orShowErr = async (res:promise<result<'a,string>>, modalRef:modalRef): 'a => {
    switch (await res) {
        | Error(msg) => {
            (await openYesNoDialog(
                ~modalRef, 
                ~title = "Internal error", 
                ~icon = <Icons.ReportGmailerrorred style=ReactDOM.Style.make(~color="red", ())/>,
                ~text = msg, 
                ~textYes = "OK", 
            ))->ignore
            Js.Exn.raiseError(msg)
        }
        | Ok(data) => data
    }
}