open Common_utils

type path = list<string>

type jsonAny = (path, JSON.t)
type jsonObj = (path, Dict.t<JSON.t>)

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
    decoder:jsonAny=>option<'a>,
) => {
    (
        (path,json):jsonAny, 
        ~validator:option<'a => result<'a,string>>=?, 
        ~default:option<'a>=?, 
        ~defaultFn:option<unit=>'a>=?, 
    ):'a => {
        switch (path,json)->decoder {
            | None => Js.Exn.raiseError(`${typeStr} was expected at '${pathToStr(path)}'.`)
            | Some(val) => Ok(val)->validate(~validator, ~default, ~defaultFn)
        }
    }
}

let makeMapperOpt = (
    typeStr:string,
    decoder:jsonAny=>option<'a>,
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
                switch (path,json)->decoder {
                    | None => Js.Exn.raiseError(`${typeStr} was expected at '${pathToStr(path)}'.`)
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
        (path,dict):jsonObj, 
        attrName:string,
        ~validator:option<'a => result<'a,string>>=?, 
        ~default:option<'a>=?, 
        ~defaultFn:option<unit=>'a>=?, 
    ):'a => {
        switch dict->Dict.get(attrName) {
            | None => Js.Exn.raiseError(`${typeStr} was expected at '${pathToStr(list{attrName, ...path})}'.`)
            | Some(json) => (list{attrName, ...path}, json)->mapper(~validator?, ~default?, ~defaultFn?)
        }
    }
}

let makeGetterOpt = (
    mapper:
        (
            jsonAny, 
            ~validator:'a => result<'a,string>=?, 
            ~default:option<'a>=?, 
            ~defaultFn:unit=>option<'a>=?, 
        ) => option<'a>
) => {
    (
        (path,dict):jsonObj, 
        attrName:string,
        ~validator:option<'a => result<'a,string>>=?, 
        ~default:option<option<'a>>=?, 
        ~defaultFn:option<unit=>option<'a>>=?, 
    ):option<'a> => {
        switch dict->Dict.get(attrName) {
            | None => None
            | Some(json) => (list{attrName, ...path}, json)->mapper(~validator?, ~default?, ~defaultFn?)
        }
    }
}

let toStr = makeMapper("A string", ((_,json)) => json->JSON.Decode.string)
let toStrOpt = makeMapperOpt("A string", ((_,json)) => json->JSON.Decode.string)
let str = makeGetter("A string", toStr)
let strOpt = makeGetterOpt(toStrOpt)

let toFloat = makeMapper("A number", ((_,json)) => json->JSON.Decode.float)
let toFloatOpt = makeMapperOpt("A number", ((_,json)) => json->JSON.Decode.float)
let float = makeGetter("A number", toFloat)
let floatOpt = makeGetterOpt(toFloatOpt)

let toInt = makeMapper("An integer", ((_,json)) => json->JSON.Decode.float->Option.map(Float.toInt))
let toIntOpt = makeMapperOpt("An integer", ((_,json)) => json->JSON.Decode.float->Option.map(Float.toInt))
let int = makeGetter("An integer", toInt)
let intOpt = makeGetterOpt(toIntOpt)

let toBool = makeMapper("A boolean", ((_,json)) => json->JSON.Decode.bool)
let toBoolOpt = makeMapperOpt("A boolean", ((_,json)) => json->JSON.Decode.bool)
let bool = makeGetter("A boolean", toBool)
let boolOpt = makeGetterOpt(toBoolOpt)

let toAny = makeMapper("Any json", jsonAny => Some(jsonAny))
let toAnyOpt = makeMapperOpt("Any json", jsonAny => Some(jsonAny))
let any = makeGetter("Any json", toAny)
let anyOpt = makeGetterOpt(toAnyOpt)

let toArr = (
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
                ->validate( ~validator, ~default, ~defaultFn )
        }
    }
}

let toArrOpt = (
    (path,json):jsonAny,
    mapper: jsonAny => 'a,
    ~validator:option<array<'a> => result<array<'a>,string>>=?, 
    ~default:option<option<array<'a>>>=?, 
    ~defaultFn:option<unit=>option<array<'a>>>=?, 
):option<array<'a>> => {
    switch json->JSON.Decode.null {
        | Some(_) => None
        | None => {
            switch json->JSON.Decode.array {
                | None => Js.Exn.raiseError(`An array was expected at '${pathToStr(path)}'.`)
                | Some(arr) => {
                    Ok(arr->Array.mapWithIndex((elem, i) => (list{i->Int.toString, ...path}, elem)->mapper)->Some)
                        ->validate(
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

let arr = (
    (path,dict):jsonObj,
    attrName:string,
    mapper: jsonAny => 'a,
    ~validator:option<array<'a> => result<array<'a>,string>>=?, 
    ~default:option<array<'a>>=?, 
    ~defaultFn:option<unit=>array<'a>>=?, 
):array<'a> => {
    switch dict->Dict.get(attrName) {
        | None => Js.Exn.raiseError(`An array was expected at '${pathToStr(list{attrName, ...path})}'`)
        | Some(json) => (list{attrName, ...path}, json)->toArr(mapper, ~validator?, ~default?, ~defaultFn?)
    }
}

let arrOpt = (
    (path,dict):jsonObj,
    attrName:string,
    mapper: jsonAny => 'a,
    ~validator:option<array<'a> => result<array<'a>,string>>=?, 
    ~default:option<option<array<'a>>>=?, 
    ~defaultFn:option<unit=>option<array<'a>>>=?, 
):option<array<'a>> => {
    switch dict->Dict.get(attrName) {
        | None => None
        | Some(json) => (list{attrName, ...path}, json)->toArrOpt(mapper, ~validator?, ~default?, ~defaultFn?)
    }
}

let toObj = (
    (path,json):jsonAny,
    mapper: jsonObj => 'a,
    ~validator:option<'a => result<'a,string>>=?, 
    ~default:option<'a>=?, 
    ~defaultFn:option<unit=>'a>=?, 
):'a => {
    switch json->JSON.Decode.object {
        | None => Js.Exn.raiseError(`An object was expected at '${pathToStr(path)}'.`)
        | Some(dict) => Ok((path, dict)->mapper)->validate( ~validator, ~default, ~defaultFn )
    }
}

let toObjOpt = (
    (path,json):jsonAny,
    mapper: jsonObj => 'a,
    ~validator:option<'a => result<'a,string>>=?, 
    ~default:option<option<'a>>=?, 
    ~defaultFn:option<unit=>option<'a>>=?, 
):option<'a> => {
    switch json->JSON.Decode.null {
        | Some(_) => None
        | None => {
            switch json->JSON.Decode.object {
                | None => Js.Exn.raiseError(`An object was expected at '${pathToStr(path)}'.`)
                | Some(dict) => {
                    Ok(Some((path, dict)->mapper))
                        ->validate(
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

let obj = (
    (path,dict):jsonObj,
    attrName:string,
    mapper: jsonObj => 'a,
    ~validator:option<'a => result<'a,string>>=?, 
    ~default:option<'a>=?, 
    ~defaultFn:option<unit=>'a>=?, 
):'a => {
    switch dict->Dict.get(attrName) {
        | None => Js.Exn.raiseError(`An object was expected at '${pathToStr(list{attrName, ...path})}'`)
        | Some(json) => (list{attrName, ...path}, json)->toObj(mapper, ~validator?, ~default?, ~defaultFn?)
    }
}

let objOpt = (
    (path,dict):jsonObj,
    attrName:string,
    mapper: jsonObj => 'a,
    ~validator:option<'a => result<'a,string>>=?, 
    ~default:option<option<'a>>=?, 
    ~defaultFn:option<unit=>option<'a>>=?, 
):option<'a> => {
    switch dict->Dict.get(attrName) {
        | None => None
        | Some(json) => (list{attrName, ...path}, json)->toObjOpt(mapper, ~validator?, ~default?, ~defaultFn?)
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

let fromJsonAny = (
    jsonAny:jsonAny, 
    mapper:jsonAny=>'a,
    ~validator:option<'a => result<'a,string>>=?, 
    ~default:option<'a>=?, 
    ~defaultFn:option<unit=>'a>=?, 
):result<'a,string> => {
    catchExn(() => jsonAny->mapper)->validateRes(~validator, ~default, ~defaultFn)
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