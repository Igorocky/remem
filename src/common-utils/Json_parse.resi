type jsonAny

let parseJson: (string, jsonAny => 'a, ~validator: 'a=>result<'a,string>=?, ~default: 'a=?, ~defaultFn: unit=>'a=?) 
    => result<'a, string>
let fromJson: (JSON.t, jsonAny => 'a, ~validator: 'a=>result<'a,string>=?, ~default: 'a=?, ~defaultFn: unit=>'a=?) 
    => result<'a, string>

let toStr: (jsonAny, 
    ~validator: string=>result<string,string>=?, ~default: string=?, ~defaultFn: unit=>string=?) 
    => string
let toStrOpt: (jsonAny, 
    ~validator: string=>result<string,string>=?, ~default: option<string>=?, ~defaultFn: unit=>option<string>=?) 
    => option<string>
let str: (jsonAny, string, 
    ~validator: string=>result<string,string>=?, ~default: string=?, ~defaultFn: unit=>string=?) 
    => string
let strOpt: (jsonAny, string, 
    ~validator: string=>result<string,string>=?, ~default: option<string>=?, ~defaultFn: unit=>option<string>=?) 
    => option<string>

let toFloat: (jsonAny,
    ~validator: float=>result<float,string>=?, ~default: float=?, ~defaultFn: unit=>float=?) 
    => float
let toFloatOpt: (jsonAny, 
    ~validator: float=>result<float,string>=?, ~default: option<float>=?, ~defaultFn: unit=>option<float>=?) 
    => option<float>
let float: (jsonAny, string, 
    ~validator: float=>result<float,string>=?, ~default: float=?, ~defaultFn: unit=>float=?) 
    => float
let floatOpt: (jsonAny, string, 
    ~validator: float=>result<float,string>=?, ~default: option<float>=?, ~defaultFn: unit=>option<float>=?) 
    => option<float>

let toInt: (jsonAny,
    ~validator: int=>result<int,string>=?, ~default: int=?, ~defaultFn: unit=>int=?) 
    => int
let toIntOpt: (jsonAny, 
    ~validator: int=>result<int,string>=?, ~default: option<int>=?, ~defaultFn: unit=>option<int>=?) 
    => option<int>
let int: (jsonAny, string, 
    ~validator: int=>result<int,string>=?, ~default: int=?, ~defaultFn: unit=>int=?) 
    => int
let intOpt: (jsonAny, string, 
    ~validator: int=>result<int,string>=?, ~default: option<int>=?, ~defaultFn: unit=>option<int>=?) 
    => option<int>

let toBool: (jsonAny,
    ~validator: bool=>result<bool,string>=?, ~default: bool=?, ~defaultFn: unit=>bool=?) 
    => bool
let toBoolOpt: (jsonAny, 
    ~validator: bool=>result<bool,string>=?, ~default: option<bool>=?, ~defaultFn: unit=>option<bool>=?) 
    => option<bool>
let bool: (jsonAny, string, 
    ~validator: bool=>result<bool,string>=?, ~default: bool=?, ~defaultFn: unit=>bool=?) 
    => bool
let boolOpt: (jsonAny, string, 
    ~validator: bool=>result<bool,string>=?, ~default: option<bool>=?, ~defaultFn: unit=>option<bool>=?) 
    => option<bool>

let toArr: (jsonAny, jsonAny => 'a, 
    ~validator:array<'a> => result<array<'a>,string>=?, ~default:array<'a>=?, ~defaultFn:unit=>array<'a>=?) 
    => array<'a>
let toArrOpt: (jsonAny, jsonAny => 'a, 
    ~validator:array<'a> => result<array<'a>,string>=?, ~default:option<array<'a>>=?, ~defaultFn:unit=>option<array<'a>>=?) 
    => option<array<'a>>
let arr: (jsonAny, string, jsonAny => 'a, 
    ~validator:array<'a> => result<array<'a>,string>=?, ~default:array<'a>=?, ~defaultFn:unit=>array<'a>=?) 
    => array<'a>
let arrOpt: (jsonAny, string, jsonAny => 'a, 
    ~validator:array<'a> => result<array<'a>,string>=?, ~default:option<array<'a>>=?, ~defaultFn:unit=>option<array<'a>>=?) 
    => option<array<'a>>