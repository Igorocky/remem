open Mui_components
open React_utils
open BE_utils
open Dtos

let method1:beFunc<Dtos.method1Req, Dtos.method1Res> = createBeFunc(Dtos.method1, Dtos.method1ResParser)
let getAllTags:beFunc<Dtos.getAllTagsReq, Dtos.getAllTagsRes> = createBeFunc(Dtos.getAllTags, Dtos.getAllTagsResParser)

@react.component
let make = () => {
    let (count, setCount) = React.useState(() => 0)

    let actSendReqToBe = async () => {
        switch (await getAllTags()) {
            | Error(msg) => Console.error(msg)
            | Ok({tags}) => Console.log2("tags = ", tags)
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
