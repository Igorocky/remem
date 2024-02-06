open Mui_components
open React_utils
open BE_utils
open React_rnd_utils
open Modal

let mainTheme = ThemeProvider.createTheme(
    {
        "palette": {
            "white": {
                "main": "#ffffff",
            },
            "grey": {
                "main": "#e0e0e0",
            },
            "lightgrey": {
                "main": "#e2e2e2",
            },
            "red": {
                "main": "#FF0000",
            },
            "pastelred": {
                "main": "#FAA0A0",
            },
            "orange": {
                "main": "#FF7900",
            },
            "yellow": {
                "main": "#FFE143",
            }
        }
    }
)

type tabData =
    | Tags
    | Search

@react.component
let make = () => {
    let modalRef = useModalRef()
    let {tabs, addTab, openTab, removeTab, renderTabs, updateTabs, activeTabId} = UseTabs.useTabs()

    React.useEffect0(()=>{
        updateTabs(st => {
            if (st->UseTabs.getTabs->Array.length == 0) {
                let (st, _) = st->UseTabs.addTab(~label="Tags", ~closable=false, ~data=Tags, ~doOpen=true)
                let (st, _) = st->UseTabs.addTab(~label="Search", ~closable=false, ~data=Search)
                st
            } else {
                st
            }
        })
        None
    })

    let rndTabContent = (top:int, tab:UseTabs.tab<'a>) => {
        <div key=tab.id style=ReactDOM.Style.make(~display=if (tab.id == activeTabId) {"block"} else {"none"}, ())>
            {
                switch tab.data {
                    | Tags => <App modalRef />
                    | Search => "Search will be here"->React.string
                }
            }
        </div>
    }

    <ThemeProvider theme=mainTheme>
        <ContentWithStickyHeader
            top=0
            header=renderTabs()
            content={contentTop => {
                <Col>
                    {React.array(tabs->Js_array2.map(rndTabContent(contentTop, _)))}
                    <Modal modalRef />
                </Col>
            }}
        />
    </ThemeProvider>
}
