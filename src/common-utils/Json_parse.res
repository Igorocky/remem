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
    ~default:option<'a>, 
    ~defaultFn:option<unit=>'a>, 
):option<'a> => {
    switch default {
        | Some(_) => default
        | None => {
            switch defaultFn {
                | None => None
                | Some(defaultFn) => Some(defaultFn())
            }
        }
    }
}

let validate = (
    res:result<'a,string>,
    ~validator:option<'a => result<'a,string>>, 
    ~default:option<'a>, 
    ~defaultFn:option<unit=>'a>, 
):'a => {
    switch res {
        | Error(msg) => {
            switch getDefaultValue( ~default, ~defaultFn, ) {
                | None => Js.Exn.raiseError(msg)
                | Some(value) => value
            }
        }
        | Ok(value) => {
            switch validator {
                | None => value
                | Some(validator) => {
                    switch validator(value) {
                        | Ok(value) => value
                        | Error(msg) => {
                            switch getDefaultValue( ~default, ~defaultFn, ) {
                                | Some(value) => value
                                | None => Js.Exn.raiseError(msg)
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
        ~default:option<'a>=?, 
        ~defaultFn:option<unit=>'a>=?, 
    ):'a => {
        switch json->decoder {
            | None => Js.Exn.raiseError(`${typeStr} was expected at '${pathToStr(path)}.'`)
            | Some(val) => Ok(val)->validate(~validator, ~default, ~defaultFn)
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
        ~default:option<option<'a>>=?, 
        ~defaultFn:option<unit=>option<'a>>=?, 
    ):option<'a> => {
        switch json->JSON.Decode.null {
            | Some(_) => None
            | None => {
                switch json->decoder {
                    | None => Js.Exn.raiseError(`${typeStr} was expected at '${pathToStr(path)}.'`)
                    | Some(val) => {
                        validate(
                            Ok(Some(val)),
                            ~validator = validator->Option.map(validator => {
                                some => {
                                    some->Option.getExn->validator->Result.map(val => Some(val))
                                }
                            }), 
                            ~default, 
                            ~defaultFn
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
            ~default:'a=?, 
            ~defaultFn:unit=>'a=?, 
        ) => 'a
) => {
    (
        (path,json):jsonAny, 
        attrName:string,
        ~validator:option<'a => result<'a,string>>=?, 
        ~default:option<'a>=?, 
        ~defaultFn:option<unit=>'a>=?, 
    ):'a => {
        switch json->JSON.Decode.object {
            | None => Js.Exn.raiseError(`An object was expected at '${pathToStr(path)}'.`)
            | Some(dict) => {
                switch dict->Dict.get(attrName) {
                    | None => Js.Exn.raiseError(`${typeStr} was expected at '${pathToStr(list{attrName, ...path})}'`)
                    | Some(json) => (list{attrName, ...path}, json)->mapper(~validator?, ~default?, ~defaultFn?)
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
            ~default:option<'a>=?, 
            ~defaultFn:unit=>option<'a>=?, 
        ) => option<'a>
) => {
    (
        (path,json):jsonAny, 
        attrName:string,
        ~validator:option<'a => result<'a,string>>=?, 
        ~default:option<option<'a>>=?, 
        ~defaultFn:option<unit=>option<'a>>=?, 
    ):option<'a> => {
        switch json->JSON.Decode.object {
            | None => Js.Exn.raiseError(`An object was expected at '${pathToStr(path)}'.`)
            | Some(dict) => {
                switch dict->Dict.get(attrName) {
                    | None => None
                    | Some(json) => (list{attrName, ...path}, json)->mapper(~validator?, ~default?, ~defaultFn?)
                }
            }
        }
    }
}

let asStr = makeMapper("A string", JSON.Decode.string)
let asStrOpt = makeMapperOpt("A string", JSON.Decode.string)
let str = makeGetter("A string", asStr)
let strOpt = makeGetterOpt("A string", asStrOpt)

let asArr = (
    (path,json):jsonAny,
    mapper: jsonAny => 'a,
    ~validator:option<array<'a> => result<array<'a>,string>>=?, 
    ~default:option<array<'a>>=?, 
    ~defaultFn:option<unit=>array<'a>>=?, 
):array<'a> => {
    switch json->JSON.Decode.array {
        | None => Js.Exn.raiseError(`An array was expected at '${pathToStr(path)}'.`)
        | Some(arr) => {
            Ok(arr->Array.mapWithIndex((elem, i) => (list{i->Int.toString, ...path}, elem)->mapper))
                ->validate(~validator, ~default, ~defaultFn)
        }
    }
}

let catchExn = (action:unit=>'a):result<'a,string> => {
    switch catchExn(action) {
        | Error({msg}) => Error(msg)
        | Ok(value) => Ok(value)
    }
}

let validateRes = (
    res:result<'a,string>,
    ~validator:option<'a => result<'a,string>>, 
    ~default:option<'a>, 
    ~defaultFn:option<unit=>'a>, 
):result<'a,string> => {
    catchExn(() => res->validate(~validator, ~default, ~defaultFn))
}

let fromJson = (
    json:JSON.t, 
    mapper:jsonAny=>'a,
    ~validator:option<'a => result<'a,string>>=?, 
    ~default:option<'a>=?, 
    ~defaultFn:option<unit=>'a>=?, 
):result<'a,string> => {
    catchExn(() => (rootPath, json)->mapper)->validateRes(~validator, ~default, ~defaultFn)
}

let parseJson = (
    jsonStr:string, 
    mapper:jsonAny=>'a, 
    ~validator:option<'a => result<'a,string>>=?, 
    ~default:option<'a>=?, 
    ~defaultFn:option<unit=>'a>=?, 
):result<'a,string> => {
    catchExn(() => (rootPath, JSON.parseExn(jsonStr))->mapper)->validateRes(~validator, ~default, ~defaultFn)
}