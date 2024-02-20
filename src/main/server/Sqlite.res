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

@send external stmtRun: (statement,'a) => statementCompletionInfo = "run"
@send external stmtRunNp: (statement) => statementCompletionInfo = "run"
@send external stmtAll: (statement,'a) => array<JSON.t> = "all"
@send external stmtAllNp: (statement) => array<JSON.t> = "all"
@send external stmtGet: (statement,'a) => JSON.t = "get"
@send external stmtGetNp: (statement) => JSON.t = "get"
