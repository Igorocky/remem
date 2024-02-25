open FE_BE_commons

type beFuncName = string
type jsonStr = string

type endpoints = {
    execBeFunc: (beFuncName,JSON.t) => promise<beResponse>
}

let makeEndpoints: Sqlite.database => endpoints