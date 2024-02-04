open Common_utils

let panic = Error.panic

@val external describe: (string, unit=>unit) => unit = "describe"
@val external describe_skip: (string, unit=>unit) => unit = "describe.skip"
@val external itPriv: (string, unit=>unit) => unit = "it"
@val external it_skip: (string, unit=>unit) => unit = "it.skip"

let it = (name:string, test:unit=>unit):unit => {
    itPriv(name, () => {
        try {
            test()
        } catch {
            | exn => {
                Console.log("##############################################################")
                Console.log2("error in test", exn)
                Console.log("##############################################################")
                raise(exn)
            }
        }
    })
}

let assertEq = (actual:'a, expected:'a): unit => {
    if (expected != actual) {
        panic(`\n  actual: ${stringify(actual)}\nexpected: ${stringify(expected)}`)
    }
}

let assertEqMsg = (actual:'a, expected:'a, msg:string) => {
    if (expected != actual) {
        panic(`\nAssertion failed for '${msg}'\n  actual: ${stringify(actual)}\nexpected: ${stringify(expected)}`)
    }
}

let assertEqNum = (actual: float, expected: float, precision: float) => {
    if (actual <= expected -. precision || actual >= expected +. precision) {
        panic(`\n  actual: ${Js.String.make(actual)}\nexpected: ${Js.String.make(expected)}`)
    }
}

let assertEqNumMsg = (actual: float, expected: float, precision: float, msg:string) => {
    if (actual <= expected -. precision || actual >= expected +. precision) {
        panic(`\nAssertion failed for '${msg}'\n  actual: ${Js.String.make(actual)}\nexpected: ${Js.String.make(expected)}`)
    }
}

let fail = () => panic("Test failed.")
let failMsg = str => panic("Test failed: " ++ str)
