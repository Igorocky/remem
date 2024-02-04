type variant = [#text|#contained|#outlined]
@module("@mui/material/Box") @react.component
external make: (
    ~sx:{..}=?,
    ~children:React.element=?
) => React.element = "default"
