type database
type statement
type statementCompletionInfo = {
    changes:int
}

@module("better-sqlite3")
@new external makeDatabase: (string,~options:'a=?) => database = "default"
@send external dbPrepare: (database,string) => statement = "prepare"

@send external stmtRun: (statement) => statementCompletionInfo = "run"
@send external stmtRunWithParams: (statement,'a) => statementCompletionInfo = "run"

