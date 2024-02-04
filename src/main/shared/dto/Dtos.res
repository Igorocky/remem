open Json_parse

module type BeFunction = {
    let name: string
    type req
    type res
    let parseReq: jsonAny => req
    let parseRes: jsonAny => res
}

type beFuncModule<'req,'res> = module(BeFunction with type req = 'req and type res = 'res)

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
let parseTagDto:jsonAny=>tagDto = toObj(_, o => {
    id: o->float("id"),
    name: o->str("name"),
})

module GetAllTags = {
    let name = "getAllTags"

    type req = unit

    let parseReq = _ => ()

    type res = {
        tags:array<tagDto>
    }

    let parseRes = toObj(_, o => { 
        tags: o->arr("tags", parseTagDto) 
    })
}
