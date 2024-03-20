type backend = {
    execBeFunc: (Endpoints.beFuncName,JSON.t) => promise<FE_BE_commons.beResponse>
}

let makeBackend = (config:{"dbFilePath":string}):backend => {
    let db = Sqlite.makeDatabase(config["dbFilePath"], ~options={"verbose": Console.log})
    Dao.initDatabase(db)
    let allTags = db->Dao.getAllTags
    if (allTags.tags->Array.length == 0) {
        db->Dao.fillDbWithRandomData(
            ~numOfTags=50,
            ~numOfCardsOfEachType=1_0,
            ~minNumOfTagsPerCard=0,
            ~maxNumOfTagsPerCard=5,
            ~histLengthPerTask=20,
            ~markProbs=[(0.,1),(1.,1)],
        )
    }
    let endpoints = Endpoints.makeEndpoints(db)
    {
        execBeFunc: endpoints.execBeFunc
    }
}