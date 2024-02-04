open Mui_components
open React_utils
open BE_utils
open Dtos

let method1:beFunc<method1Req, method1Res> = createBeFunc(method1, method1ResParser)

@react.component
let make = () => {
    let (count, setCount) = React.useState(() => 0)

    let actSendReqToBe = async () => {
        switch (await method1({text:"qweasdzxc"})) {
            | Error(msg) => Console.error(msg)
            | Ok({len}) => Console.log2("len = ", len)
        }
    }

    let clickAction = () => {
        setCount(count => count + 1)
        actSendReqToBe()->ignore
    }

    <Button onClick=clickHnd(~act=clickAction)>
        {React.string(`count is ${count->Int.toString}`)}
    </Button>
}
