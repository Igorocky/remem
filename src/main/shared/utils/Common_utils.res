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

type parsedEpochTime = {
    year:int,
    month:int,
    day:int,
    hours:int,
    minutes:int,
    seconds:int,
    milliseconds:int,
}

let parseEpochTime = (ms:Date.msSinceEpoch):parsedEpochTime => {
    let date = ms->Date.fromTime
    {
        year:date->Date.getFullYear,
        month:date->Date.getMonth,
        day:date->Date.getDate,
        hours:date->Date.getHours,
        minutes:date->Date.getMinutes,
        seconds:date->Date.getSeconds,
        milliseconds:date->Date.getMilliseconds,
    }
}

type timeRange =
    | Last1Hour
    | Last2Hours
    | Last4Hours
    | Last8Hours
    | Last24Hours
    | Today
    | Yesterday
    | Last2Days
    | Last3Days
    | Last7Days
    | Range(option<Date.msSinceEpoch>,option<Date.msSinceEpoch>)

let parseTimeRange = (range:timeRange, currTime:Date.msSinceEpoch)
    :(option<Date.msSinceEpoch>,option<Date.msSinceEpoch>) => {
    switch range {
        | Range(left,right) => (left,right)
        | Last1Hour => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day,
                    ~hours=parsed.hours-1,
                    ~minutes=parsed.minutes,
                    ~seconds=parsed.seconds,
                    ~milliseconds=parsed.milliseconds,
                )->Date.getTime),
                None
            )
        }
        | Last2Hours => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day,
                    ~hours=parsed.hours-2,
                    ~minutes=parsed.minutes,
                    ~seconds=parsed.seconds,
                    ~milliseconds=parsed.milliseconds,
                )->Date.getTime),
                None
            )
        }
        | Last4Hours => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day,
                    ~hours=parsed.hours-4,
                    ~minutes=parsed.minutes,
                    ~seconds=parsed.seconds,
                    ~milliseconds=parsed.milliseconds,
                )->Date.getTime),
                None
            )
        }
        | Last8Hours => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day,
                    ~hours=parsed.hours-8,
                    ~minutes=parsed.minutes,
                    ~seconds=parsed.seconds,
                    ~milliseconds=parsed.milliseconds,
                )->Date.getTime),
                None
            )
        }
        | Last24Hours => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day,
                    ~hours=parsed.hours-24,
                    ~minutes=parsed.minutes,
                    ~seconds=parsed.seconds,
                    ~milliseconds=parsed.milliseconds,
                )->Date.getTime),
                None
            )
        }
        | Today => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day,
                    ~hours=0,
                    ~minutes=0,
                    ~seconds=0,
                    ~milliseconds=0,
                )->Date.getTime),
                None
            )
        }
        | Yesterday => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day-1,
                    ~hours=0,
                    ~minutes=0,
                    ~seconds=0,
                    ~milliseconds=0,
                )->Date.getTime),
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day,
                    ~hours=0,
                    ~minutes=0,
                    ~seconds=0,
                    ~milliseconds=0,
                )->Date.getTime)
            )
        }
        | Last2Days => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day-1,
                    ~hours=0,
                    ~minutes=0,
                    ~seconds=0,
                    ~milliseconds=0,
                )->Date.getTime),
                None
            )
        }
        | Last3Days => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day-2,
                    ~hours=0,
                    ~minutes=0,
                    ~seconds=0,
                    ~milliseconds=0,
                )->Date.getTime),
                None
            )
        }
        | Last7Days => {
            let parsed = parseEpochTime(currTime)
            (
                Some(Date.makeWithYMDHMSM(
                    ~year=parsed.year,
                    ~month=parsed.month,
                    ~date=parsed.day-6,
                    ~hours=0,
                    ~minutes=0,
                    ~seconds=0,
                    ~milliseconds=0,
                )->Date.getTime),
                None
            )
        }
    }
}