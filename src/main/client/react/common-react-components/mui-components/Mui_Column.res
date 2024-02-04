open React_utils

@react.component
let make = (
    ~gridRef:option<ReactDOM.domRef>=?,
    ~justifyContent:option<Mui_Grid.justifyContent>=?,
    ~alignItems:option<Mui_Grid.alignItems>=?,
    ~spacing:float=1.,
    ~style:option<ReactDOMStyle.t>=?,
    ~childXsOffset:option<int=>option<Js.Json.t>>=?,
    ~children:option<React.element>=?
) => {
    <Mui_Grid ref=?gridRef container=true direction=#column ?justifyContent ?alignItems spacing ?style >
        {switch children {
            | Some(children) => 
                children->React.Children.mapWithIndex((child,i) => {
                    let style = switch reElem2Obj(child)->Js.Nullable.toOption {
                        | None => None
                        | Some(childObj) => {
                            switch childObj["props"]->Js.Nullable.toOption {
                                | None => None
                                | Some(childProps) => {
                                    switch childProps["style"]->Js.Nullable.toOption {
                                        | None => None
                                        | Some(childStyle) => {
                                            switch childStyle["display"]->Js.Nullable.toOption {
                                                | None => None
                                                | Some(childDisplay) => {
                                                    if (childDisplay === "none") {
                                                        Some(ReactDOM.Style.make(~display="none", ()))
                                                    } else {
                                                        None
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    <Mui_Grid 
                        ?style
                        xsOffset=?{ childXsOffset->Belt_Option.flatMap(childXsOffset => childXsOffset(i)) }
                    >
                        child
                    </Mui_Grid>
                } )
            | None => React.null
        }}
    </Mui_Grid>
}