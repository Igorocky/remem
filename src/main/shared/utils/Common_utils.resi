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

type parsedEpochTime = {
    year:int,
    month:int,
    day:int,
    hours:int,
    minutes:int,
    seconds:int,
    milliseconds:int,
}

let parseEpochTime: Date.msSinceEpoch => parsedEpochTime

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

let parseTimeRange: (timeRange, Date.msSinceEpoch) => (option<Date.msSinceEpoch>,option<Date.msSinceEpoch>)