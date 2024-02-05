open Mui_components
open React_utils
open BE_utils

let getAllTags:beFunc<Dtos.GetAllTags.req, Dtos.GetAllTags.res> = createBeFunc(module(Dtos.GetAllTags))
let createTag = createBeFunc(module(Dtos.CreateTag))

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
