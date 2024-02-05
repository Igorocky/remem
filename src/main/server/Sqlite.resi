type database
type statement
type statementCompletionInfo = {changes: int}

let makeDatabase: (string,~options:'a=?) => database

let dbPrepare: (database,string) => statement
let dbPragma: (database, string) => 'a
let dbPragmaFull: (database,string) => array<{..}>

let stmtRun: statement => statementCompletionInfo
let stmtRunWithParams: (statement,'a) => statementCompletionInfo
let stmtAll: (statement) => array<JSON.t>
let stmtAllWithParams: (statement,'a) => array<JSON.t>
