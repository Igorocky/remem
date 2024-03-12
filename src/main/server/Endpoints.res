open Common_utils
open FE_BE_commons

type beFuncName = string
type jsonStr = string
type endpoints = {
    execBeFunc: (beFuncName,JSON.t) => promise<beResponse>
}

external castJsonToAny: JSON.t => 'a = "%identity"
external castAnyToJson: 'a => JSON.t = "%identity"

let isEmptyResponse = %raw("x => x === undefined")

let addBeFuncToMap = (
    endpointsMap:Belt.HashMap.String.t<JSON.t=>promise<beResponse>>, 
    name:string, method:'req=>'res
):unit => {
    endpointsMap->Belt.HashMap.String.set(name, json => {
        Promise.make((resolve,_) => {
            switch catchExn(() => json->castJsonToAny->method) {
                | Error({exn,msg}) => {
                    let errMsg = `Internal error: ${msg}`
                    Console.error(errMsg)
                    Console.error(exn)
                    resolve({ err: Some(errMsg), data:None, emptyResp:None })
                }
                | Ok(res) => {
                    if (isEmptyResponse(res)) {
                        resolve({ err: None, data:None, emptyResp:Some(true) })
                    } else {
                        resolve({ err: None, data:Some(res->castAnyToJson), emptyResp:None })
                    }
                }
            }
        })
    })
}

// https://forum.rescript-lang.org/t/how-to-use-the-first-class-module-in-rescript/3238/5
let registerBeFunc = (
    type req, 
    type res, 
    endpointsMap:Belt.HashMap.String.t<JSON.t=>promise<beResponse>>, 
    m:Dto_utils.beFuncModule<req,res>, 
    func:req=>res
): unit => {
    module M = unpack(m)
    addBeFuncToMap(endpointsMap, M.name, func )
}

let execBeMethod = (
    endpointsMap:Belt.HashMap.String.t<JSON.t=>promise<beResponse>>, 
    name:string,
    data:JSON.t,
):promise<beResponse> => {
    switch endpointsMap->Belt.HashMap.String.get(name) {
        | None => Js.Exn.raiseError(`Cannot find a handler for the method '${name}'`)
        | Some(hnd) => hnd(data)
    }
}

let makeEndpoints = (db:Sqlite.database):endpoints => {
    let endpointsMap:Belt.HashMap.String.t<JSON.t=>promise<beResponse>> = Belt.HashMap.String.make(~hintSize=100)
    registerBeFunc(endpointsMap, module(Dtos.GetAllTags), () => Dao.getAllTags(db) )
    registerBeFunc(endpointsMap, module(Dtos.CreateTag), Dao.createTag(db, _) )
    registerBeFunc(endpointsMap, module(Dtos.UpdateTag), Dao.updateTag(db, _) )
    registerBeFunc(endpointsMap, module(Dtos.DeleteTags), Dao.deleteTags(db, _) )
    registerBeFunc(endpointsMap, module(Dtos.FindCards), Dao.findCards(db, _) )
    registerBeFunc(endpointsMap, module(Dtos.DeleteCard), Dao.deleteCard(db, _) )
    registerBeFunc(endpointsMap, module(Dtos.RestoreCard), Dao.restoreCard(db, _) )
    registerBeFunc(endpointsMap, module(Dtos.CreateCard), Dao.createCard(db, _) )
    {
        execBeFunc: execBeMethod(endpointsMap, ...)
    }
}