open Common_utils

@react.component
let make: (~label: string, ~initRange: timeRange=?, ~onChange: timeRange => unit) => React.element
