let stringify = any => {
    switch any->JSON.stringifyAny {
        | Some(str) => str
        | None => {
            Console.log2("Could not stringify this value", any)
            Error.panic("Could not stringify a value")
        }
    }
}

let startProfile: unit => unit = %raw(`() => console.profile()`)
let stopProfile: unit => unit = %raw(`() => console.profileEnd()`)

type exnData = {
    exn:exn,
    msg:string,
    stack:string,
}

let catchExn = (run:unit=>'a): result<'a,exnData> => {
    try {
        Ok(run())
    } catch {
        | exn => {
            let jsExn = exn->Error.fromException
            Error({
                exn,
                msg: jsExn->Option.flatMap(Error.message)->Option.getOr("Unknown error."),
                stack: jsExn->Option.flatMap(Error.stack)->Option.getOr(""),
            })
        }
    }
}