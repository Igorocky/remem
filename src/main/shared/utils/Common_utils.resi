let stringify: 'a => string
let startProfile: unit => unit
let stopProfile: unit => unit

type exnData = {
    exn:exn,
    msg:string,
    stack:string,
}

let catchExn: (unit=>'a) => result<'a,exnData>

type comparator<'a> = ('a, 'a) => float

let comparatorByInt: ('a=>int) => comparator<'a>

let comparatorByFloat: ('a=>float) => comparator<'a>

let comparatorByStr: ('a=>string) => comparator<'a>

let comparatorAndThen: (comparator<'a>, comparator<'a>) => comparator<'a>

let comparatorInverse: comparator<'a> => comparator<'a>