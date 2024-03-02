type database
type statement
type statementCompletionInfo = {
    changes:int
}

@module("better-sqlite3")
@new external makeDatabase: (string,~options:'a=?) => database = "default"
@send external dbPrepare: (database,string) => statement = "prepare"
@send external dbPragma: (database, string, @as(json`{simple:true}`) _) => 'a = "pragma"
@send external dbPragmaFull: (database,string) => array<{..}> = "pragma"
@send external dbExec: (database,string) => database = "exec"
@send external dbTransaction: (database,'a=>'b) => ('a=>'b) = "transaction"

@send external stmtRun: (statement,'a) => statementCompletionInfo = "run"
@send external stmtRunNp: (statement) => statementCompletionInfo = "run"
@send external stmtAll: (statement,'a) => array<JSON.t> = "all"
@send external stmtAllNp: (statement) => array<JSON.t> = "all"
@send external stmtGet: (statement,'a) => JSON.t = "get"
@send external stmtGetNp: (statement) => JSON.t = "get"

let dbRun = (db:database,query:string,params:'a):statementCompletionInfo => {
    db->dbPrepare(query)->stmtRun(params)
}

let dbRunNp = (db:database,query:string):statementCompletionInfo => {
    db->dbPrepare(query)->stmtRunNp
}

let dbAll = (db:database,query:string,params:'a):array<JSON.t> => {
    db->dbPrepare(query)->stmtAll(params)
}

let dbAllNp = (db:database,query:string):array<JSON.t> => {
    db->dbPrepare(query)->stmtAllNp
}

let dbGet = (db:database,query:string,params:'a):JSON.t => {
    db->dbPrepare(query)->stmtGet(params)
}

let dbGetNp = (db:database,query:string):JSON.t => {
    db->dbPrepare(query)->stmtGetNp
}
