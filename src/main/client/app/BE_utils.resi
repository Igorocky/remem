type beFunc<'req,'resp> = 'req => promise<result<'resp,string>>

let createBeFunc: Dto_utils.beFuncModule<'req,'res> => beFunc<'req,'res>
