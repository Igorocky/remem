open React_common_components

type modalId = string

type modalMethods = {
    openModal: (unit=>React.element) => promise<modalId>,
    openModalFullScreen: (unit=>React.element) => promise<modalId>,
    updateModal: (modalId, (unit => React.element)) => unit,
    closeModal: modalId => unit,
}

type modalRef = React.ref<Js.Nullable.t<modalMethods>>
let useModalRef = () => {
    React.useRef(Js.Nullable.null)
}

let modalRefToModalMethods: modalRef => modalMethods = modalRef => {
    switch modalRef.current->Js.Nullable.toOption {
        | None => Js.Exn.raiseError(`modalRef.current is null`)
        | Some(modalMethods) => modalMethods
    }
}

let openModal = (modalRef:modalRef, render:unit=>React.element):promise<modalId> => modalRefToModalMethods(modalRef).openModal(render)
let openModalFullScreen = (modalRef:modalRef, render:unit=>React.element):promise<modalId> => modalRefToModalMethods(modalRef).openModalFullScreen(render)
let updateModal = (modalRef:modalRef, modalId:modalId, render:unit=>React.element):unit => modalRefToModalMethods(modalRef).updateModal(modalId, render)
let closeModal = (modalRef:modalRef, modalId:modalId):unit => modalRefToModalMethods(modalRef).closeModal(modalId)

type modal = {
    id: modalId,
    fullScreen:bool,
    render: unit => React.element
}

type state = {
    nextId: int,
    modals: array<modal>,
}

let createInitialState = () => {
    {
        nextId: 0,
        modals: [],
    }
}

let openModalPriv = (st, fullScreen, render) => {
    let id = st.nextId->Belt_Int.toString
    (
        {
            nextId: st.nextId+1,
            modals: st.modals->Js_array2.concat([{
                id,
                fullScreen,
                render
            }])
        },
        id
    )
}

let updateModalPriv = (st,id,newRender) => {
    {
        ...st,
        modals: st.modals->Js_array2.map(m => if m.id == id {{...m, render:newRender}} else {m})
    }
}

let closeModalPriv = (st,id) => {
    {
        ...st,
        modals: st.modals->Js_array2.filter(m => m.id != id)
    }
}

@react.component
let make = (~modalRef:modalRef) => {
    let (state, setState) = React.useState(createInitialState)

    modalRef.current = React.useMemo0(() => {
        Js.Nullable.return(
            {
                openModal: render => Promise.make((rlv,_) => {
                    setState(prev => {
                        let (st, id) = prev->openModalPriv(false, render)
                        rlv(id)
                        st
                    })
                }),
                openModalFullScreen: render => Promise.make((rlv,_) => {
                    setState(prev => {
                        let (st, id) = prev->openModalPriv(true, render)
                        rlv(id)
                        st
                    })
                }),
                updateModal: (modalId, render) => {
                    setState(updateModalPriv(_, modalId, render))
                },
                closeModal: modalId => {
                    setState(closeModalPriv(_, modalId))
                }
            }
        )
    })

    <>
    {
        state.modals
            ->Js.Array2.map(modal=>{
                <Dialog 
                    key=modal.id 
                    opn=true 
                    maxWidth=?(if (modal.fullScreen) {None} else {Some("xl")})
                    fullScreen=modal.fullScreen
                >
                    {modal.render()}
                </Dialog>
            })
            ->React.array
    }
    </>
}