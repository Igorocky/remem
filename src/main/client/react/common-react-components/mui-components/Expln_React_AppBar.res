type position = [ #absolute | #fixed | #relative | #static | #sticky ]

@module("@mui/material/AppBar") @react.component
external make: (
    ~position: position=?,
    ~color: string=?,
    ~children: React.element,
) => React.element = "default"
