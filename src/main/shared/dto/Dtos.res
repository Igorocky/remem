open Json_parse

let method1 = "method1"
type method1Req = {
    text:string
}
let method1ReqParser:jsonAny=>method1Req = toObj(_, o => {
    text: o->str("text")
})
type method1Res = {
    len:int
}
let method1ResParser:jsonAny=>method1Res = toObj(_, o => { len: o->int("len") })

type tagDto = {
    id:float,
    name:string,
}
let getAllTags = "getAllTags"
type getAllTagsReq = unit
let getAllTagsReqParser:jsonAny=>getAllTagsReq = _ => ()
type getAllTagsRes = {
    tags:array<tagDto>
}
let getAllTagsResParser:jsonAny=>getAllTagsRes = toObj(_, o => { 
    tags: o->arr("tags", toObj(_, o => {
        id: o->float("id"),
        name: o->str("name"),
    })) 
})