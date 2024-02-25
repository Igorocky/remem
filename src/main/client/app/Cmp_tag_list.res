open Mui_components
open React_utils
open React_rnd_utils
open Modal

@react.component
let make = (
    ~modalRef:modalRef,
    ~allTags:array<Dtos.tagDto>,
    ~createTag:Dtos.tagDto=>unit,
    ~updateTag:Dtos.tagDto=>unit,
    ~deleteTag:Dtos.tagDto=>unit,
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

    let actUpdateTag = (tag:Dtos.tagDto) => {
        openModal(modalRef, modalId => {
            <Cmp_tag_edit 
                tag
                onSave={tag => {
                    updateTag(tag)
                    closeModal(modalRef, modalId)
                }} 
                onCancel={() => closeModal(modalRef, modalId)} 
            />
        })

    }

    let actDeleteTag = async (tag:Dtos.tagDto) => {
        let deleteConfirmed = await openYesNoDialog(
            ~modalRef,
            ~text=`Delete '${tag.name}'`,
            ~textYes="Delete",
            ~textNo="Cancel",
        )
        if (deleteConfirmed) {
            deleteTag(tag)
        }
    }

    let rndAllTags = () => {
        if (allTags->Array.length == 0) {
            "There are no tags."->React.string
        } else {
            <table>
                <tbody>
                    {
                        allTags->Array.map(tag => {
                            <tr key=tag.id>
                                <td>{tag.name->React.string}</td>
                                <td>{rndSmallTextBtn(~text="edit", ~color="lightgrey", ~onClick=()=>actUpdateTag(tag))}</td>
                                <td>{rndSmallTextBtn(~text="delete", ~color="lightgrey", ~onClick=()=>actDeleteTag(tag)->ignore)}</td>
                            </tr>
                        })->React.array
                    }
                </tbody>
            </table>
        }
    }

    <Col style=ReactDOM.Style.make(~margin="15px", ())>
        <Button onClick=clickHnd(~act=actCreateNewTag) color="lightgrey" variant=#contained>
            {React.string("New tag")}
        </Button>
        {rndAllTags()}
    </Col>
}
