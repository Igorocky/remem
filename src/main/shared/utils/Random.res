let randSelect = (samples:array<('a,int)>): 'a => {
    let sum = samples->Array.map(((_,i)) => i)->Array.reduce(0, (acc,elem) => acc + elem)
    let randCnt = Js.Math.random_int(0,sum)
    let (_,res) = samples->Array.reduce(
        (-1,None),
        (res,(elem,prob)) => {
            switch res {
                | (_,Some(_)) => res
                | (cnt,None) => {
                    let cnt = cnt + prob
                    if (randCnt <= cnt) {
                        (cnt,Some(elem))
                    } else {
                        (cnt,None)
                    }
                }
            }
        }
    )
    switch res {
        | None => Js.Exn.raiseError("Cannot select random element in randSelect")
        | Some(elem) => elem
    }
}

let randText = (
    ~minLen:int,
    ~maxLen:int,
    ~letterProb:int=10,
    ~digitProb:int=1,
    ~spaceProb:int=60,
): string => {
    if (minLen > maxLen) {
        Js.Exn.raiseError("minLen > maxLen")
    }
    let samples = []
    if (letterProb > 0) {
        samples->Array.pushMany(
            Belt.Array.range(
                "a"->String.charCodeAt(0)->Float.toInt,
                "z"->String.charCodeAt(0)->Float.toInt,
            )->Array.map(i => (i->String.fromCharCode, letterProb))
        )
    }
    if (digitProb > 0) {
        samples->Array.pushMany(
            Belt.Array.range(
                "0"->String.charCodeAt(0)->Float.toInt,
                "9"->String.charCodeAt(0)->Float.toInt,
            )->Array.map(i => (i->String.fromCharCode, digitProb))
        )
    }
    if (spaceProb > 0) {
        samples->Array.push((" ", spaceProb))
    }
    let strLen = Js.Math.random_int(minLen, maxLen+1)
    let res = Array.make(~length=strLen, "")
    for i in 0 to strLen-1 {
        res->Array.setUnsafe(i, randSelect(samples))
    }
    res->Array.joinWith("")
}