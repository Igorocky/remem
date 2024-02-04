open Json_parse
open Dtos

let beEndpoints:Belt.HashMap.String.t<JSON.t=>promise<string>> = Belt.HashMap.String.make(~hintSize=100)

let execBeMethod = (name:string,data:JSON.t):promise<string> => {
    switch beEndpoints->Belt.HashMap.String.get(name) {
        | None => Js.Exn.raiseError(`Cannot find a handler for the method '${name}'`)
        | Some(hnd) => hnd(data)
    }
}

let registerBeMethod = (name:string, inpParser:jsonAny=>'a, method:'a => promise<'b>):unit => {
    beEndpoints->Belt.HashMap.String.set(name, json => {
        switch fromJson(json, inpParser) {
            | Error(msg) => {
                Js.Exn.raiseError(`Error parsing input request for the BE method '${name}': ${msg}`)
            }
            | Ok(req) => req->method->Promise.thenResolve(Common_utils.stringify)
        }
    })
}

registerBeMethod(
    method1,
    method1ReqParser,
    (req:method1Req) => {
        Promise.resolve(
            {
                len: req.text->String.length
            }
        )
    }
)