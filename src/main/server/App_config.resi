type backend = {
    execBeFunc: (Endpoints.beFuncName, JSON.t) => promise<Endpoints.jsonStr>,
}

let makeBackend: unit => backend
