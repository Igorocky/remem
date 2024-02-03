type jsonAny

let parseJson: (
    string, 
    jsonAny => 'a, 
    ~validator: 'a=>result<'a,string>=?, 
    ~defaultVal: 'a=?,
    ~default: unit=>'a=?,
) => result<'a, string>

let fromJson: (
    JSON.t, 
    jsonAny => 'a,
    ~validator: 'a=>result<'a,string>=?, 
    ~defaultVal: 'a=?,
    ~default: unit=>'a=?,
) => result<'a, string>

let asStr: (
    jsonAny,
    ~validator: string=>result<string,string>=?, 
    ~defaultVal: string=?,
    ~default: unit=>string=?,
) => string

let asStrOpt: (
    jsonAny,
    ~validator: string=>result<string,string>=?, 
    ~defaultVal: option<string>=?,
    ~default: unit=>option<string>=?,
) => option<string>

let str: (
    jsonAny,
    string,
    ~validator: string=>result<string,string>=?, 
    ~defaultVal: string=?,
    ~default: unit=>string=?,
) => string

let strOpt: (
    jsonAny,
    string,
    ~validator: string=>result<string,string>=?, 
    ~defaultVal: option<string>=?,
    ~default: unit=>option<string>=?,
) => option<string>

let asArr: (
    jsonAny, 
    jsonAny => 'a,
    ~validator:array<'a> => result<array<'a>,string>=?, 
    ~defaultVal:array<'a>=?, 
    ~default:unit=>array<'a>=?, 
) => array<'a>