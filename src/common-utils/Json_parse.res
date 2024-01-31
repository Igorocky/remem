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
    ~path:path,
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

let fromJson = (
    json:JSON.t, 
    mapper:jsonAny=>result<'a,string>,
    ~validator:option<'a => result<'a,string>>=?, 
    ~default:option<unit=>'a>=?, 
    ~defaultVal:option<'a>=?, 
):result<'a,string> => {
    switch catchExn(() => {
        (rootPath, json)->mapper->Result.flatMap(resultValue => {
            resultValue->validate(
                ~path=rootPath,
                ~validator, 
                ~default, 
                ~defaultVal, 
            )
        })
    }) {
        | Ok(res) => res
        | Error({msg}) => Error(msg)
    }
}

let parseJson = (
    jsonStr:string, 
    mapper:jsonAny=>result<'a,string>, 
    ~validator:option<'a => result<'a,string>>=?, 
    ~default:option<unit=>'a>=?, 
    ~defaultVal:option<'a>=?, 
):result<'a,string> => {
    switch catchExn(() => {
        JSON.parseExn(jsonStr)->fromJson( mapper, ~validator?, ~default?, ~defaultVal?, )
    }) {
        | Ok(res) => res
        | Error({msg}) => Error(msg)
    }
}