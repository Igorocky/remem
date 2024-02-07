open Mui_components
open React_utils

type state = {
    tag:Dtos.tagDto
}

let makeState = (initialValues:option<Dtos.tagDto>) => {
    switch initialValues {
        | Some(tagInit) => {tag:tagInit}
        | None => {tag:{id:"",name:""}}
    }
}

@react.component
let make = (
    ~tag:option<Dtos.tagDto>=?,
    ~onSave:Dtos.tagDto=>unit,
    ~onCancel:unit=>unit,
) => {
    let (state, setState) = React.useState(() => makeState(tag))

    let rndTitle = () => {
        <span style=ReactDOM.Style.make(~fontWeight="bold", ~fontSize="15px", ())>
            {
                switch tag {
                    | None => "Create Tag"->React.string
                    | Some(_) => "Edit Tag"->React.string
                }
            }
        </span>
    }

    <Paper style=ReactDOM.Style.make( ~padding="10px", () ) >
        <Col>
            {rndTitle()}
            <TextField 
                size=#small
                style=ReactDOM.Style.make(~width="300px", ())
                label="Name" 
                value=state.tag.name
                onChange=evt2str(newName => setState(st => {tag:{...st.tag, name:newName}}))
                autoFocus=true
            />
            <Row>
                <Button onClick=clickHnd(~act=()=>onSave(state.tag)) color="primary" variant=#contained>
                    {React.string("Save")}
                </Button>
                <Button onClick=clickHnd(~act=onCancel) variant=#outlined>
                    {React.string("Cancel")}
                </Button>
            </Row>
        </Col>
    </Paper>
}
