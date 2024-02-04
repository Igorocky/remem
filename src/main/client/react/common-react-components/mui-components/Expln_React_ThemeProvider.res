

type muiTheme

@module("@mui/material/styles")
external createTheme: {..} => muiTheme = "createTheme"

@module("@mui/material/styles") @react.component
external make: (
    ~theme: muiTheme,
    ~children: React.element,
) => React.element = "ThemeProvider"
