type beFunc<'req,'resp> = 'req => promise<result<'resp,string>>

let createBeFunc: Dtos.beFuncModule<'req,'res> => beFunc<'req,'res>
