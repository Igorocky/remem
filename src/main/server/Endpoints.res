open Json_parse
open Common_utils
open FE_BE_commons

type beFuncName = string
type jsonStr = string
type endpoints = {
    execBeFunc: (beFuncName,JSON.t) => promise<jsonStr>
}

external castJsonToAny: JSON.t => 'a = "%identity"

let isEmptyResponse = %raw("x => x === undefined")

let addBeFuncToMap = (
    endpointsMap:Belt.HashMap.String.t<JSON.t=>promise<string>>, 
    name:string, method:'req => promise<'res>
):unit => {
    endpointsMap->Belt.HashMap.String.set(name, json => {
        //todo: Use Promise.make
        switch catchExn(() => json->castJsonToAny->method) {
            | Error({exn,msg}) => {
                let errMsg = `Internal error: ${msg}`
                Console.error(errMsg)
                Console.error(exn)
                { err: Some(errMsg), data:None, emptyResp:None }->Common_utils.stringify->Promise.resolve
            }
            | Ok(res) => {
                res
                    ->Promise.thenResolve(res => {
                        if (isEmptyResponse(res)) {
                            { err: None, data:None, emptyResp:Some(true) }
                        } else {
                            { err: None, data:Some(res), emptyResp:None }
                        }
                    })
                    ->Promise.thenResolve(Common_utils.stringify)
            }
        }
    })
}

// https://forum.rescript-lang.org/t/how-to-use-the-first-class-module-in-rescript/3238/5
let registerBeFunc = (
    type req, 
    type res, 
    endpointsMap:Belt.HashMap.String.t<JSON.t=>promise<string>>, 
    m:Dto_utils.beFuncModule<req,res>, 
    func:req => promise<res>
): unit => {
    module M = unpack(m)
    addBeFuncToMap(endpointsMap, M.name, func )
}

let execBeMethod = (
    endpointsMap:Belt.HashMap.String.t<JSON.t=>promise<string>>, 
    name:string,
    data:JSON.t,
):promise<string> => {
    switch endpointsMap->Belt.HashMap.String.get(name) {
        | None => Js.Exn.raiseError(`Cannot find a handler for the method '${name}'`)
        | Some(hnd) => hnd(data)
    }
}

let makeEndpoints = (db:Sqlite.database):endpoints => {
    let endpointsMap:Belt.HashMap.String.t<JSON.t=>promise<string>> = Belt.HashMap.String.make(~hintSize=100)
    registerBeFunc(endpointsMap, module(Dtos.GetAllTags), () => Dao.getAllTags(db) )
    registerBeFunc(endpointsMap, module(Dtos.CreateTag), Dao.createTag(db, _) )
    registerBeFunc(endpointsMap, module(Dtos.UpdateTag), Dao.updateTag(db, _) )
    registerBeFunc(endpointsMap, module(Dtos.DeleteTags), Dao.deleteTags(db, _) )
    registerBeFunc(endpointsMap, module(Dtos.CreateTranslateCard), Dao.createTranslateCard(db, _) )
    {
        execBeFunc: execBeMethod(endpointsMap, ...)
    }
}