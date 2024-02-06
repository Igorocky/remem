open Mui_components
open React_utils
open BE_utils
open React_rnd_utils
open Modal

let getAllTags:beFunc<Dtos.GetAllTags.req, Dtos.GetAllTags.res> = createBeFunc(module(Dtos.GetAllTags))
let createTag = createBeFunc(module(Dtos.CreateTag))
let deleteTags = createBeFunc(module(Dtos.DeleteTags))

@react.component
let make = (
    ~modalRef:modalRef,
) => {
    let (count, setCount) = React.useState(() => 0)

    let orErr = orShowErr(_, modalRef)

    let actSendReqToBe = async () => {
        let allTags = await getAllTags()->orErr
        Console.log2("tags = ", allTags)
    }

    let clickAction = () => {
        setCount(count => count + 1)
        actSendReqToBe()->ignore
    }

    <Button onClick=clickHnd(~act=clickAction)>
        {React.string(`count is ${count->Int.toString}`)}
    </Button>
}
