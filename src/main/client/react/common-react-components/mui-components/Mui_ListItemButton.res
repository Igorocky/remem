

@module("@mui/material/ListItemButton") @react.component
external make: (
    ~onClick: ReactEvent.Mouse.t=>unit=?,
    ~children: React.element=?
) => React.element = "default"
