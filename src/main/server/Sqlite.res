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
@send external dbRunScript: (database,string) => database = "exec"
@send external dbTransactionPriv: (database,'a=>'b) => ('a=>'b) = "transaction"

@send external stmtUpdate: (statement,'a) => statementCompletionInfo = "run"
@send external stmtUpdateNp: (statement) => statementCompletionInfo = "run"
@send external stmtSelect: (statement,'a) => array<JSON.t> = "all"
@send external stmtSelectNp: (statement) => array<JSON.t> = "all"
@send external stmtSelectSingle: (statement,'a) => JSON.t = "get"
@send external stmtSelectSingleNp: (statement) => JSON.t = "get"

let dbUpdateInf = (db:database,query:string,params:'a):statementCompletionInfo => {
    db->dbPrepare(query)->stmtUpdate(params)
}

let dbUpdate = (db:database,query:string,params:'a):unit => {
    dbUpdateInf(db, query, params)->ignore
}

let dbUpdateNpInf = (db:database,query:string):statementCompletionInfo => {
    db->dbPrepare(query)->stmtUpdateNp
}

let dbUpdateNp = (db:database,query:string):unit => {
    dbUpdateNpInf(db, query)->ignore
}

let dbSelect = (db:database,query:string,params:'a):array<JSON.t> => {
    db->dbPrepare(query)->stmtSelect(params)
}

let dbSelectNp = (db:database,query:string):array<JSON.t> => {
    db->dbPrepare(query)->stmtSelectNp
}

let dbSelectSingle = (db:database,query:string,params:'a):JSON.t => {
    db->dbPrepare(query)->stmtSelectSingle(params)
}

let dbSelectSingleNp = (db:database,query:string):JSON.t => {
    db->dbPrepare(query)->stmtSelectSingleNp
}

let dbTransaction = (db:database, func:unit=>'a):'a => {
    (db->dbTransactionPriv(func))()
}