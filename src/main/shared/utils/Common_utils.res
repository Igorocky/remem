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

type comparator<'a> = ('a, 'a) => float

let comparatorByInt = (prop:'a=>int):comparator<'a> => {
    (a,b) => {
        let propA = prop(a)
        let propB = prop(b)
        if (propA < propB) {
            -1.
        } else if (propA == propB) {
            0.
        } else {
            1.
        }
    }
}

let comparatorByFloat = (prop:'a=>float):comparator<'a> => {
    (a,b) => {
        let propA = prop(a)
        let propB = prop(b)
        if (propA < propB) {
            -1.
        } else if (propA == propB) {
            0.
        } else {
            1.
        }
    }
}

let comparatorByStr = (prop:'a=>string):comparator<'a> => {
    (a,b) => {
        let propA = prop(a)
        let propB = prop(b)
        if (propA < propB) {
            -1.
        } else if (propA == propB) {
            0.
        } else {
            1.
        }
    }
}

let comparatorAndThen = (cmp1:comparator<'a>, cmp2:comparator<'a>):comparator<'a> => {
    (x,y) => {
        switch cmp1(x,y) {
            | 0. => cmp2(x,y)
            | i => i
        }
    }
}

let comparatorInverse = (cmp:comparator<'a>):comparator<'a> => (x,y) => -. cmp(x,y)