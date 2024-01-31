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