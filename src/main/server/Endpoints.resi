type beFuncName = string
type jsonStr = string

type endpoints = {
    execBeFunc: (beFuncName,JSON.t) => promise<jsonStr>
}

let makeEndpoints: Sqlite.database => endpoints