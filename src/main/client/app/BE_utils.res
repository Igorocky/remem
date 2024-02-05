open Json_parse

@val external fetch: (string,'a) => promise<{..}> = "fetch"

let parseBeResp = (respStr:string, dataMapper:jsonAny=>'a): result<'a,string> => {
    let parsed = parseJson(respStr, toObj(_, o => {
        (
            o->anyOpt("data"),
            o->strOpt("err"),
        )
    }))

    switch parsed {
        | Error(msg) => {
            Console.error2(`An error occured during parse of the BE response: parse error is '${msg}', ` ++
                `BE response is `, respStr)
            Error(msg)
        }
        | Ok((dataOpt,errOpt)) => {
            switch errOpt {
                | Some(msg) => Error(msg)
                | None => {
                    switch dataOpt {
                        | None => {
                            Js_console.error2(`BE response doesn't contain neither 'data' nor 'err':`, respStr)
                            Error(`BE response doesn't contain neither 'data' nor 'err'.`)
                        }
                        | Some(data) => fromJsonAny(data, dataMapper)
                    }
                }
            }
        }
    }
}

type beFunc<'req,'resp> = 'req => promise<result<'resp,string>>

let createBeFuncPriv = (url:string, respMapper:jsonAny => 'resp): beFunc<'req,'resp> => {
    req => {
        fetch("/be/" ++ url, {
            "method": "POST",
            "headers": {
                "Content-Type": "application/json;charset=UTF-8"
            },
            "body": JSON.stringifyAny(req)
        }) 
            ->Promise.then(res => res["text"]())
            ->Promise.thenResolve(text => parseBeResp(text,respMapper))
    }
}

// https://forum.rescript-lang.org/t/how-to-use-the-first-class-module-in-rescript/3238/5
let createBeFunc = (type req, type res, m:Dto_utils.beFuncModule<req,res>): beFunc<req,res> => {
    module M = unpack(m)
    createBeFuncPriv(M.name, M.parseRes)
}