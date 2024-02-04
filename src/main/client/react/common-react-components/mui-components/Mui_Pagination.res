

@module("@mui/material/Pagination") @react.component
external make: (
    ~count:int,
    ~page:int,
    ~siblingCount:int=?,
    ~onChange:(_,int) => unit,
) => React.element = "default"
