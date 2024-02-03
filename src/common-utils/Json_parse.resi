type jsonAny

let parseJson: (
    string, 
    jsonAny => 'a, 
    ~validator: 'a=>result<'a,string>=?, 
    ~default: 'a=?,
    ~defaultFn: unit=>'a=?,
) => result<'a, string>

let fromJson: (
    JSON.t, 
    jsonAny => 'a,
    ~validator: 'a=>result<'a,string>=?, 
    ~default: 'a=?,
    ~defaultFn: unit=>'a=?,
) => result<'a, string>

let toStr: (
    jsonAny,
    ~validator: string=>result<string,string>=?, 
    ~default: string=?,
    ~defaultFn: unit=>string=?,
) => string

let toStrOpt: (
    jsonAny,
    ~validator: string=>result<string,string>=?, 
    ~default: option<string>=?,
    ~defaultFn: unit=>option<string>=?,
) => option<string>

let str: (
    jsonAny,
    string,
    ~validator: string=>result<string,string>=?, 
    ~default: string=?,
    ~defaultFn: unit=>string=?,
) => string

let strOpt: (
    jsonAny,
    string,
    ~validator: string=>result<string,string>=?, 
    ~default: option<string>=?,
    ~defaultFn: unit=>option<string>=?,
) => option<string>

let toArr: (
    jsonAny, 
    jsonAny => 'a,
    ~validator:array<'a> => result<array<'a>,string>=?, 
    ~default:array<'a>=?, 
    ~defaultFn:unit=>array<'a>=?, 
) => array<'a>

let toArrOpt: (
    jsonAny, 
    jsonAny => 'a,
    ~validator:array<'a> => result<array<'a>,string>=?, 
    ~default:option<array<'a>>=?, 
    ~defaultFn:unit=>option<array<'a>>=?, 
) => option<array<'a>>

let arr: (
    jsonAny, 
    string,
    jsonAny => 'a,
    ~validator:array<'a> => result<array<'a>,string>=?, 
    ~default:array<'a>=?, 
    ~defaultFn:unit=>array<'a>=?, 
) => array<'a>

let arrOpt: (
    jsonAny, 
    string,
    jsonAny => 'a,
    ~validator:array<'a> => result<array<'a>,string>=?, 
    ~default:option<array<'a>>=?, 
    ~defaultFn:unit=>option<array<'a>>=?, 
) => option<array<'a>>