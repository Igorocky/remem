

type orientation = [ #horizontal | #vertical ]

@module("@mui/material/Divider") @react.component
external make: (
    ~orientation:orientation=?,
) => React.element = "default"
