type backend = {
    execBeFunc: (Endpoints.beFuncName,JSON.t) => promise<FE_BE_commons.beResponse>
}

let makeBackend = ():backend => {
    let db = Sqlite.makeDatabase("./remem.sqlite", ~options={"verbose": Console.log})
    Dao.initDatabase(db)
    let endpoints = Endpoints.makeEndpoints(db)
    {
        execBeFunc: endpoints.execBeFunc
    }
}