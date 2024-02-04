open Json_parse

type beFunc<'req,'resp> = 'req => promise<result<'resp,string>>

let createBeFunc: (string, jsonAny => 'resp) => beFunc<'req,'resp>
