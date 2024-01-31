let stringify: 'a => string
let startProfile: unit => unit
let stopProfile: unit => unit

type exnData = {
    exn:exn,
    msg:string,
    stack:string,
}

let catchExn: (unit=>'a) => result<'a,exnData>