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
    let registerDaoFunc = ( 
        type req, type res, m:Dto_utils.beFuncModule<req,res>, daoFunc:(Sqlite.database,req)=>res 
    ): unit => {
        registerBeFunc(endpointsMap, m, daoFunc(db, _))
    }
    registerDaoFunc(module(Dtos.GetAllTags), (db,_) => Dao.getAllTags(db))
    registerDaoFunc(module(Dtos.CreateTag), Dao.createTag)
    registerDaoFunc(module(Dtos.UpdateTag), Dao.updateTag)
    registerDaoFunc(module(Dtos.DeleteTags), Dao.deleteTags)
    registerDaoFunc(module(Dtos.GetRemainingTags), Dao.getRemainingTags)
    registerDaoFunc(module(Dtos.FindCards), Dao.findCards)
    registerDaoFunc(module(Dtos.DeleteCard), Dao.deleteCard)
    registerDaoFunc(module(Dtos.RestoreCard), Dao.restoreCard)
    registerDaoFunc(module(Dtos.CreateCard), Dao.createCard)
    registerDaoFunc(module(Dtos.UpdateCard), Dao.updateCard)
    {
        execBeFunc: execBeMethod(endpointsMap, ...)
    }
}