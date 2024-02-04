

type variant = [#text|#contained|#outlined]
type size = [#small|#medium|#large]
@module("@mui/material/ButtonGroup") @react.component
external make: (
    ~variant:variant=?,
    ~size:size=?,
    ~disabled:bool=?,
    ~color:string=?,
    ~children: React.element
) => React.element = "default"
