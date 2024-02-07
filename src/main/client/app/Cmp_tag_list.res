open Mui_components
open React_utils
open BE_utils
open React_rnd_utils
open Modal

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
    ~createTag:Dtos.tagDto=>unit,
) => {
    let actCreateNewTag = () => {
        openModal(modalRef, modalId => {
            <Cmp_tag_edit 
                onSave={tag => {
                    createTag(tag)
                    closeModal(modalRef, modalId)
                }} 
                onCancel={() => closeModal(modalRef, modalId)} 
            />
        })

    }

    let rndAllTags = () => {
        <table>
            <tbody>
                {
                    allTags->Array.map(tag => {
                        <tr key=tag.id>
                            <td>{tag.name->React.string}</td>
                            <td>{"edit"->React.string}</td>
                            <td>{"delete"->React.string}</td>
                        </tr>
                    })->React.array
                }
            </tbody>
        </table>
    }

    <Col style=ReactDOM.Style.make(~margin="15px", ())>
        <Button onClick=clickHnd(~act=actCreateNewTag) color="lightgrey" variant=#contained>
            {React.string("New tag")}
        </Button>
        {rndAllTags()}
    </Col>
}
