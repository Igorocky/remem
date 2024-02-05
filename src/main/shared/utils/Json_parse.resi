type jsonAny
type jsonObj

let parseJson: (string, jsonAny => 'a, ~validator: 'a=>result<'a,string>=?, ~default: 'a=?, ~defaultFn: unit=>'a=?) 
    => result<'a, string>
let parseJsonExn: (string, jsonAny => 'a, ~validator: 'a=>result<'a,string>=?, ~default: 'a=?, ~defaultFn: unit=>'a=?) 
    => 'a
let fromJson: (JSON.t, jsonAny => 'a, ~validator: 'a=>result<'a,string>=?, ~default: 'a=?, ~defaultFn: unit=>'a=?) 
    => result<'a, string>
let fromJsonExn: (JSON.t, jsonAny => 'a, ~validator: 'a=>result<'a,string>=?, ~default: 'a=?, ~defaultFn: unit=>'a=?) 
    => 'a
let fromJsonAny: (jsonAny, jsonAny => 'a, ~validator: 'a=>result<'a,string>=?, ~default: 'a=?, ~defaultFn: unit=>'a=?) 
    => result<'a, string>
let fromJsonAnyExn: (jsonAny, jsonAny => 'a, ~validator: 'a=>result<'a,string>=?, ~default: 'a=?, ~defaultFn: unit=>'a=?) 
    => 'a

let toStr: (jsonAny, 
    ~validator: string=>result<string,string>=?, ~default: string=?, ~defaultFn: unit=>string=?) 
    => string
let toStrOpt: (jsonAny, 
    ~validator: string=>result<string,string>=?, ~default: option<string>=?, ~defaultFn: unit=>option<string>=?) 
    => option<string>
let str: (jsonObj, string, 
    ~validator: string=>result<string,string>=?, ~default: string=?, ~defaultFn: unit=>string=?) 
    => string
let strOpt: (jsonObj, string, 
    ~validator: string=>result<string,string>=?, ~default: option<string>=?, ~defaultFn: unit=>option<string>=?) 
    => option<string>

let toFloat: (jsonAny,
    ~validator: float=>result<float,string>=?, ~default: float=?, ~defaultFn: unit=>float=?) 
    => float
let toFloatOpt: (jsonAny, 
    ~validator: float=>result<float,string>=?, ~default: option<float>=?, ~defaultFn: unit=>option<float>=?) 
    => option<float>
let float: (jsonObj, string, 
    ~validator: float=>result<float,string>=?, ~default: float=?, ~defaultFn: unit=>float=?) 
    => float
let floatOpt: (jsonObj, string, 
    ~validator: float=>result<float,string>=?, ~default: option<float>=?, ~defaultFn: unit=>option<float>=?) 
    => option<float>

let toInt: (jsonAny,
    ~validator: int=>result<int,string>=?, ~default: int=?, ~defaultFn: unit=>int=?) 
    => int
let toIntOpt: (jsonAny, 
    ~validator: int=>result<int,string>=?, ~default: option<int>=?, ~defaultFn: unit=>option<int>=?) 
    => option<int>
let int: (jsonObj, string, 
    ~validator: int=>result<int,string>=?, ~default: int=?, ~defaultFn: unit=>int=?) 
    => int
let intOpt: (jsonObj, string, 
    ~validator: int=>result<int,string>=?, ~default: option<int>=?, ~defaultFn: unit=>option<int>=?) 
    => option<int>

let toBool: (jsonAny,
    ~validator: bool=>result<bool,string>=?, ~default: bool=?, ~defaultFn: unit=>bool=?) 
    => bool
let toBoolOpt: (jsonAny, 
    ~validator: bool=>result<bool,string>=?, ~default: option<bool>=?, ~defaultFn: unit=>option<bool>=?) 
    => option<bool>
let bool: (jsonObj, string, 
    ~validator: bool=>result<bool,string>=?, ~default: bool=?, ~defaultFn: unit=>bool=?) 
    => bool
let boolOpt: (jsonObj, string, 
    ~validator: bool=>result<bool,string>=?, ~default: option<bool>=?, ~defaultFn: unit=>option<bool>=?) 
    => option<bool>

let toAny: (jsonAny,
    ~validator: jsonAny=>result<jsonAny,string>=?, ~default: jsonAny=?, ~defaultFn: unit=>jsonAny=?) 
    => jsonAny
let toAnyOpt: (jsonAny, 
    ~validator: jsonAny=>result<jsonAny,string>=?, ~default: option<jsonAny>=?, ~defaultFn: unit=>option<jsonAny>=?) 
    => option<jsonAny>
let any: (jsonObj, string, 
    ~validator: jsonAny=>result<jsonAny,string>=?, ~default: jsonAny=?, ~defaultFn: unit=>jsonAny=?) 
    => jsonAny
let anyOpt: (jsonObj, string, 
    ~validator: jsonAny=>result<jsonAny,string>=?, ~default: option<jsonAny>=?, ~defaultFn: unit=>option<jsonAny>=?) 
    => option<jsonAny>

let toArr: (jsonAny, jsonAny => 'a, 
    ~validator:array<'a> => result<array<'a>,string>=?, ~default:array<'a>=?, ~defaultFn:unit=>array<'a>=?) 
    => array<'a>
let toArrOpt: (jsonAny, jsonAny => 'a, 
    ~validator:array<'a> => result<array<'a>,string>=?, ~default:option<array<'a>>=?, ~defaultFn:unit=>option<array<'a>>=?) 
    => option<array<'a>>
let arr: (jsonObj, string, jsonAny => 'a, 
    ~validator:array<'a> => result<array<'a>,string>=?, ~default:array<'a>=?, ~defaultFn:unit=>array<'a>=?) 
    => array<'a>
let arrOpt: (jsonObj, string, jsonAny => 'a, 
    ~validator:array<'a> => result<array<'a>,string>=?, ~default:option<array<'a>>=?, ~defaultFn:unit=>option<array<'a>>=?) 
    => option<array<'a>>

let toObj: (jsonAny, jsonObj => 'a, 
    ~validator:'a => result<'a,string>=?, ~default:'a=?, ~defaultFn:unit=>'a=?) 
    => 'a
let toObjOpt: (jsonAny, jsonObj => 'a, 
    ~validator:'a => result<'a,string>=?, ~default:option<'a>=?, ~defaultFn:unit=>option<'a>=?) 
    => option<'a>
let obj: (jsonObj, string, jsonObj => 'a, 
    ~validator:'a => result<'a,string>=?, ~default:'a=?, ~defaultFn:unit=>'a=?) 
    => 'a
let objOpt: (jsonObj, string, jsonObj => 'a, 
    ~validator:'a => result<'a,string>=?, ~default:option<'a>=?, ~defaultFn:unit=>option<'a>=?) 
    => option<'a>