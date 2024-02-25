type backend = {
    execBeFunc: (Endpoints.beFuncName,JSON.t) => promise<FE_BE_commons.beResponse>
}

let makeBackend: unit => backend
