type beResponse<'a> = {
    data:option<'a>,
    emptyResponse:option<bool>,
    err:option<string>,
}