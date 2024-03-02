type database
type statement
type statementCompletionInfo = {changes: int}

let makeDatabase: (string,~options:'a=?) => database

let dbPrepare: (database,string) => statement
let dbExec: (database,string) => database
let dbPragma: (database, string) => 'a
let dbPragmaFull: (database,string) => array<{..}>
let dbTransaction: (database,'a=>'b) => ('a=>'b)

let stmtRun: (statement,'a) => statementCompletionInfo
let stmtRunNp: statement => statementCompletionInfo
let stmtAll: (statement,'a) => array<JSON.t>
let stmtAllNp: (statement) => array<JSON.t>
let stmtGet: (statement,'a) => JSON.t
let stmtGetNp: (statement) => JSON.t

let dbRun: (database,string,'a) => statementCompletionInfo
let dbRunNp: (database,string) => statementCompletionInfo
let dbAll: (database,string,'a) => array<JSON.t>
let dbAllNp: (database,string) => array<JSON.t>
let dbGet: (database,string,'a) => JSON.t
let dbGetNp: (database,string) => JSON.t
