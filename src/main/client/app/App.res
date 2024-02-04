open Mui_components
open React_utils

@react.component
let make = () => {
    let (count, setCount) = React.useState(() => 0)

    <Button onClick=clickHnd(~act=()=>setCount(count => count + 1))>
        {React.string(`count is ${count->Int.toString}`)}
    </Button>
}
