open Common_utils

type path = list<string>

type jsonAny = (path, JSON.t)

let rootPath = list{}

let pathToStr = path => {
    switch path {
        | list{} => "/"
        | _ => path->List.reduceReverse("", (a,e) => a ++ "/" ++ e)
    }
}

let getDefaultValue = (
    ~default:option<unit=>'a>, 
    ~defaultVal:option<'a>, 
):option<'a> => {
    switch defaultVal {
        | Some(_) => defaultVal
        | None => {
            switch default {
                | None => None
                | Some(default) => Some(default())
            }
        }
    }
}

let validate = (
    value:'a,
    ~validator:option<'a => result<'a,string>>, 
    ~default:option<unit=>'a>, 
    ~defaultVal:option<'a>, 
):result<'a,string> => {
    switch validator {
        | None => Ok(value)
        | Some(validator) => {
            switch validator(value) {
                | Ok(value) => Ok(value)
                | Error(msg) => {
                    switch getDefaultValue( ~default, ~defaultVal, ) {
                        | Some(value) => Ok(value)
                        | None => Error(msg)
                    }
                }
            }
        }
    }
}

let makeMapper = (
    typeStr:string,
    decoder:JSON.t=>option<'a>,
) => {
    (
        (path,json):jsonAny, 
        ~validator:option<'a => result<'a,string>>=?, 
        ~defaultVal:option<'a>=?, 
        ~default:option<unit=>'a>=?, 
    ):result<'a,string> => {
        switch json->decoder {
            | None => Error(typeStr ++ " was expected at " ++ pathToStr(path))
            | Some(val) => val->validate(~validator, ~defaultVal, ~default)
        }
    }
}

let makeMapperOpt = (
    typeStr:string,
    decoder:JSON.t=>option<'a>,
) => {
    (
        (path,json):jsonAny, 
        ~validator:option<'a => result<'a,string>>=?, 
        ~defaultVal:option<option<'a>>=?, 
        ~default:option<unit=>option<'a>>=?, 
    ):result<option<'a>,string> => {
        switch json->JSON.Decode.null {
            | Some(_) => Ok(None)
            | None => {
                switch json->decoder {
                    | None => {
                        Error(typeStr ++ " was expected at " ++ pathToStr(path))
                    }
                    | Some(val) => {
                        validate(
                            Some(val),
                            ~validator = validator->Option.map(validator => {
                                some => {
                                    some->Option.getExn->validator->Result.map(val => Some(val))
                                }
                            }), 
                            ~defaultVal, 
                            ~default
                        )
                    }
                }
            }
        }
    }
}

let makeGetter = (
    typeStr:string,
    mapper:
        (
            jsonAny, 
            ~validator:'a => result<'a,string>=?, 
            ~defaultVal:'a=?, 
            ~default:unit=>'a=?, 
        ) => result<'a,string>
) => {
    (
        (path,json):jsonAny, 
        attrName:string,
        ~validator:option<'a => result<'a,string>>=?, 
        ~defaultVal:option<'a>=?, 
        ~default:option<unit=>'a>=?, 
    ):result<'a,string> => {
        switch json->JSON.Decode.object {
            | None => Error(`An object was expected at '${pathToStr(path)}'`)
            | Some(dict) => {
                switch dict->Dict.get(attrName) {
                    | None => Error(`${typeStr} was expected at '${pathToStr(list{attrName, ...path})}'`)
                    | Some(json) => (list{attrName, ...path}, json)->mapper(~validator?, ~defaultVal?, ~default?)
                }
            }
        }
    }
}

let makeGetterOpt = (
    typeStr:string,
    mapper:
        (
            jsonAny, 
            ~validator:'a => result<'a,string>=?, 
            ~defaultVal:option<'a>=?, 
            ~default:unit=>option<'a>=?, 
        ) => result<option<'a>,string>
) => {
    (
        (path,json):jsonAny, 
        attrName:string,
        ~validator:option<'a => result<'a,string>>=?, 
        ~defaultVal:option<option<'a>>=?, 
        ~default:option<unit=>option<'a>>=?, 
    ):result<option<'a>,string> => {
        switch json->JSON.Decode.object {
            | None => Error(`An object was expected at '${pathToStr(path)}'`)
            | Some(dict) => {
                switch dict->Dict.get(attrName) {
                    | None => Ok(None)
                    | Some(json) => (list{attrName, ...path}, json)->mapper(~validator?, ~defaultVal?, ~default?)
                }
            }
        }
    }
}

let asStr = makeMapper("A string", JSON.Decode.string)
let asStrOpt = makeMapperOpt("A string", JSON.Decode.string)
let str = makeGetter("A string", asStr)
let strOpt = makeGetterOpt("A string", asStrOpt)

let fromJson = (
    json:JSON.t, 
    mapper:jsonAny=>result<'a,string>,
    ~validator:option<'a => result<'a,string>>=?, 
    ~defaultVal:option<'a>=?, 
    ~default:option<unit=>'a>=?, 
):result<'a,string> => {
    (rootPath, json)->mapper->Result.flatMap(validate(_, ~validator, ~defaultVal, ~default))
}

let parseJson = (
    jsonStr:string, 
    mapper:jsonAny=>result<'a,string>, 
    ~validator:option<'a => result<'a,string>>=?, 
    ~defaultVal:option<'a>=?, 
    ~default:option<unit=>'a>=?, 
):result<'a,string> => {
    switch catchExn(() => JSON.parseExn(jsonStr)) {
        | Error({msg}) => Error(msg)
        | Ok(json) => json->fromJson(mapper, ~validator?, ~defaultVal?, ~default?)
    }
}