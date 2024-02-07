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
    ~allTags:array<Dtos.tagDto>
) => {
    

    let getExn = getExn(_, modalRef)

    // let actSendReqToBe = async () => {
    //     let allTags = await getAllTags()->getExn
    //     Console.log2("tags = ", allTags)
    // }

    // let clickAction = () => {
    //     setCount(count => count + 1)
    //     actSendReqToBe()->ignore
    // }

    // <Button onClick=clickHnd(~act=clickAction)>
    //     {React.string(`count is ${count->Int.toString}`)}
    // </Button>

    let rndAllTags = () => {
        <table>
            <tbody>
                // {
                //     allTags->Array
                // }
            </tbody>
        </table>
    }

    rndAllTags()
}
