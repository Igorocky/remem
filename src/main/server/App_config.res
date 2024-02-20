type backend = {
    execBeFunc: (Endpoints.beFuncName,JSON.t) => promise<Endpoints.jsonStr>
}

let makeBackend = ():backend => {
    let db = Sqlite.makeDatabase("./remem.sqlite")
    Dao.initDatabase(db)
    let endpoints = Endpoints.makeEndpoints(db)
    {
        execBeFunc: endpoints.execBeFunc
    }
}