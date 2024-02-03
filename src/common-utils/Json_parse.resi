type jsonAny

let parseJson: (
    string, 
    jsonAny => result<'a,string>, 
    ~validator: 'a=>result<'a,string>=?, 
    ~defaultVal: 'a=?,
    ~default: unit=>'a=?,
) => result<'a, string>

let fromJson: (
    JSON.t, 
    jsonAny => result<'a,string>,
    ~validator: 'a=>result<'a,string>=?, 
    ~defaultVal: 'a=?,
    ~default: unit=>'a=?,
) => result<'a, string>

let asStr: (
    jsonAny,
    ~validator: string=>result<string,string>=?, 
    ~defaultVal: string=?,
    ~default: unit=>string=?,
) => result<string, string>

let asStrOpt: (
    jsonAny,
    ~validator: string=>result<string,string>=?, 
    ~defaultVal: option<string>=?,
    ~default: unit=>option<string>=?,
) => result<option<string>, string>

let str: (
    jsonAny,
    string,
    ~validator: string=>result<string,string>=?, 
    ~defaultVal: string=?,
    ~default: unit=>string=?,
) => result<string, string>

let strOpt: (
    jsonAny,
    string,
    ~validator: string=>result<string,string>=?, 
    ~defaultVal: option<string>=?,
    ~default: unit=>option<string>=?,
) => result<option<string>, string>

let asArr: (
    jsonAny, 
    jsonAny => result<'a,string>,
    ~validator:array<'a> => result<array<'a>,string>=?, 
    ~defaultVal:array<'a>=?, 
    ~default:unit=>array<'a>=?, 
) => result<array<'a>,string>