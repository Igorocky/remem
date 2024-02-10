@react.component
let make: (~label: string, ~initRange: Dtos.timeRange=?, ~onChange: Dtos.timeRange => unit) => React.element
