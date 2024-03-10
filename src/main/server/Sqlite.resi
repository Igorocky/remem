type database
type statement
type statementCompletionInfo = {changes: int}

let makeDatabase: (string,~options:'a=?) => database

let dbPrepare: (database,string) => statement
let dbRunScript: (database,string) => database
let dbPragma: (database, string) => 'a
let dbPragmaFull: (database,string) => array<{..}>
let dbTransaction: (database,unit=>'a) => 'a

let stmtUpdate: (statement,'a) => statementCompletionInfo
let stmtUpdateNp: statement => statementCompletionInfo
let stmtSelect: (statement,'a) => array<JSON.t>
let stmtSelectNp: (statement) => array<JSON.t>
let stmtSelectSingle: (statement,'a) => JSON.t
let stmtSelectSingleNp: (statement) => JSON.t

let dbUpdate: (database,string,'a) => unit
let dbUpdateInf: (database,string,'a) => statementCompletionInfo
let dbUpdateNp: (database,string) => unit
let dbUpdateNpInf: (database,string) => statementCompletionInfo
let dbSelect: (database,string,'a) => array<JSON.t>
let dbSelectNp: (database,string) => array<JSON.t>
let dbSelectSingle: (database,string,'a) => JSON.t
let dbSelectSingleNp: (database,string) => JSON.t
