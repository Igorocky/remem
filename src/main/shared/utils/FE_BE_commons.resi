type beResponse<'a> = {
    data:option<'a>,
    emptyResp:option<bool>,
    err:option<string>,
}