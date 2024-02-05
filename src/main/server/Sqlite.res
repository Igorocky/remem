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

@send external stmtRun: (statement) => statementCompletionInfo = "run"
@send external stmtRunWithParams: (statement,'a) => statementCompletionInfo = "run"
@send external stmtAll: (statement) => array<JSON.t> = "all"
@send external stmtAllWithParams: (statement,'a) => array<JSON.t> = "all"
