open Json_parse
open Common_utils

let beEndpoints:Belt.HashMap.String.t<JSON.t=>promise<string>> = Belt.HashMap.String.make(~hintSize=100)

let execBeMethod = (name:string,data:JSON.t):promise<string> => {
    switch beEndpoints->Belt.HashMap.String.get(name) {
        | None => Js.Exn.raiseError(`Cannot find a handler for the method '${name}'`)
        | Some(hnd) => hnd(data)
    }
}

let registerBeFuncPriv = (name:string, inpParser:jsonAny=>'a, method:'a => promise<'b>):unit => {
    beEndpoints->Belt.HashMap.String.set(name, json => {
        switch fromJson(json, inpParser) {
            | Error(msg) => {
                let errMsg = `Internal error: cannot parse input request for the BE method '${name}': ${msg}`
                Console.error(errMsg)
                { "err": errMsg }->Common_utils.stringify->Promise.resolve
            }
            | Ok(req) => {
                switch catchExn(() => req->method) {
                    | Error({exn,msg}) => {
                        let errMsg = `Internal error: ${msg}`
                        Console.error(errMsg)
                        Console.error(exn)
                        { "err": errMsg }->Common_utils.stringify->Promise.resolve
                    }
                    | Ok(res) => res->Promise.thenResolve(res => {"data":res}->Common_utils.stringify)
                }
            }
        }
    })
}

// https://forum.rescript-lang.org/t/how-to-use-the-first-class-module-in-rescript/3238/5
let registerBeFunc = (type req, type res, m:Dto_utils.beFuncModule<req,res>, func:req => promise<res>): unit => {
    module M = unpack(m)
    registerBeFuncPriv( M.name, M.parseReq, func )
}

registerBeFunc( module(Dtos.GetAllTags), Dao.getAllTags )
registerBeFunc( module(Dtos.CreateTag), Dao.createTag )