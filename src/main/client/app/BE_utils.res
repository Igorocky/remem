open Common_utils
open FE_BE_commons

@val external fetch: (string,'a) => promise<{..}> = "fetch"

external castJsonToAny: JSON.t => 'a = "%identity"

let parseBeResp: string => result<JSON.t,string> = respStr => {
    let parsed = switch catchExn(() => JSON.parseExn(respStr)) {
        | Error({msg}) => Error(msg)
        | Ok(respJson) => {
            let resp: beResponse<JSON.t> = respJson->castJsonToAny
            Ok((resp.data, resp.emptyResp, resp.err))
        }
    }

    switch parsed {
        | Error(msg) => {
            Console.error2(`An error occured during parse of the BE response: parse error is '${msg}', ` ++
                `BE response is `, respStr)
            Error(msg)
        }
        | Ok((dataOpt,emptOpt,errOpt)) => {
            switch errOpt {
                | Some(msg) => Error(msg)
                | None => {
                    switch dataOpt {
                        | Some(data) => Ok(data)
                        | None => {
                            switch emptOpt {
                                | None => {
                                    Js_console.error2(`BE response doesn't contain neither 'data' nor 'err':`, respStr)
                                    Error(`BE response doesn't contain neither 'data' nor 'err'.`)
                                }
                                | Some(_) => Ok(JSON.Encode.null)
                            }
                        }
                    }
                }
            }
        }
    }
}

type beFunc<'req,'resp> = 'req => promise<result<'resp,string>>

let createBeFuncPriv = (url:string): beFunc<'req,'resp> => {
    req => {
        fetch("/be/" ++ url, {
            "method": "POST",
            "headers": {
                "Content-Type": "application/json;charset=UTF-8"
            },
            "body": JSON.stringifyAny(req)
        }) 
            ->Promise.then(res => res["text"]())
            ->Promise.thenResolve(text => parseBeResp(text)->Result.map(castJsonToAny))
    }
}

// https://forum.rescript-lang.org/t/how-to-use-the-first-class-module-in-rescript/3238/5
let createBeFunc = (type req, type res, m:Dto_utils.beFuncModule<req,res>): beFunc<req,res> => {
    module M = unpack(m)
    createBeFuncPriv(M.name)
}