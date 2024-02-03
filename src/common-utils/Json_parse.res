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
    ~defaultVal:option<'a>, 
    ~default:option<unit=>'a>, 
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
    res:result<'a,string>,
    ~validator:option<'a => result<'a,string>>, 
    ~default:option<unit=>'a>, 
    ~defaultVal:option<'a>, 
):result<'a,string> => {
    switch res {
        | Error(_) => {
            switch getDefaultValue( ~defaultVal, ~default, ) {
                | None => res
                | Some(value) => Ok(value)
            }
        }
        | Ok(value) => {
            switch validator {
                | None => res
                | Some(validator) => {
                    switch validator(value) {
                        | Ok(value) => Ok(value)
                        | Error(msg) => {
                            switch getDefaultValue( ~defaultVal, ~default, ) {
                                | Some(value) => Ok(value)
                                | None => Error(msg)
                            }
                        }
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
            | Some(val) => Ok(val)->validate(~validator, ~defaultVal, ~default)
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
                            Ok(Some(val)),
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

@new external newArray: int=>array<'a> = "Array"

let asArr = (
    (path,json):jsonAny, 
    mapper: jsonAny => result<'a,string>,
    ~validator:option<array<'a> => result<array<'a>,string>>=?, 
    ~defaultVal:option<array<'a>>=?, 
    ~default:option<unit=>array<'a>>=?, 
):result<array<'a>,string> => {
    switch json->JSON.Decode.array {
        | None => Error(`An array was expected at '${pathToStr(path)}'`)
        | Some(arr) => {
            arr->Array.reduceWithIndex(
                Ok(newArray(arr->Array.length)),
                (res, elem, i) => {
                    switch res {
                        | Error(_) => res
                        | Ok(resArr) => {
                            switch mapper((list{i->Int.toString, ...path}, arr->Array.getUnsafe(i))) {
                                | Error(msg) => Error(msg)
                                | Ok(mappedElem) => {
                                    resArr[i] = mappedElem
                                    res
                                }
                            }
                        }
                    }
                }
            )->validate(~validator, ~defaultVal, ~default)
        }
    }
}

let fromJson = (
    json:JSON.t, 
    mapper:jsonAny=>result<'a,string>,
    ~validator:option<'a => result<'a,string>>=?, 
    ~defaultVal:option<'a>=?, 
    ~default:option<unit=>'a>=?, 
):result<'a,string> => {
    (rootPath, json)->mapper->validate(~validator, ~defaultVal, ~default)
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
        | Ok(json) => (rootPath, json)->mapper
    }->validate(~validator, ~defaultVal, ~default)
}