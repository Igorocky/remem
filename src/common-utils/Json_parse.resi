type jsonAny

let parseJson: (
    string, 
    jsonAny => result<'a,string>, 
    ~validator: 'a=>result<'a,string>=?, 
    ~default: unit=>'a =?,
    ~defaultVal: 'a =?,
) => result<'a, string>

let fromJson: (
    JSON.t, 
    jsonAny => result<'a,string>,
    ~validator: 'a=>result<'a,string>=?, 
    ~default: unit=>'a =?,
    ~defaultVal: 'a =?,
) => result<'a, string>

