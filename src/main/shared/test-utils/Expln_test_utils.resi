let describe: (string, unit=>unit) => unit
let describe_skip: (string, unit=>unit) => unit
let it: (string, unit => unit) => unit
let itAsync: (string, unit=>promise<unit>) => unit
let itSkip: (string, unit=>unit) => unit

let assertEq: ('a, 'a) => unit
let assertEqMsg: ('a, 'a, string) => unit
let assertEqNum: (float, float, float) => unit
let assertEqNumMsg: (float, float, float, string) => unit

let fail: unit => 'a
let failMsg: string => 'a
