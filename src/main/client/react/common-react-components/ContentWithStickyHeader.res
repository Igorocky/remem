open UseResizeObserver

@react.component
let make = (~top:int=0, ~header:React.element, ~content:int=>React.element) => {
    let (contentTop, setContentTop) = React.useState(_ => top)

    let headerRef = React.useRef(Js.Nullable.null)
    useClientSizeObserver(headerRef, (_, headerHeight) => setContentTop(_ => top + headerHeight))

    <>
        <div 
            ref=ReactDOM.Ref.domRef(headerRef) 
            style=ReactDOM.Style.make(~position="sticky", ~top=`${top->Belt_Int.toString}px`, ~zIndex="1000", ~background="white", ())
        >
            {header}
        </div>
        {content(contentTop)}
    </>
}