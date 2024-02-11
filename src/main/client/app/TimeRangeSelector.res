open Mui_components
open React_utils
open BE_utils
open React_rnd_utils
open Modal
open Common_utils
open React_rnd_utils

type state = {
    range: timeRange,
}

let timeRangeToStr = range => {
    switch range {
        | Last1Hour => "Last1Hour"
        | Last2Hours => "Last2Hours"
        | Last4Hours => "Last4Hours"
        | Last8Hours => "Last8Hours"
        | Last24Hours => "Last24Hours"
        | Today => "Today"
        | Yesterday => "Yesterday"
        | Last2Days => "Last2Days"
        | Last3Days => "Last3Days"
        | Last7Days => "Last7Days"
        | Range(_,_) => "Range"
    }
}

let strToTimeRange = str => {
    switch str {
        | "Last1Hour" => Last1Hour
        | "Last2Hours" => Last2Hours
        | "Last4Hours" => Last4Hours
        | "Last8Hours" => Last8Hours
        | "Last24Hours" => Last24Hours
        | "Today" => Today
        | "Yesterday" => Yesterday
        | "Last2Days" => Last2Days
        | "Last3Days" => Last3Days
        | "Last7Days" => Last7Days
        | _ => Range(None,None)
    }
}

let monthToStr = i => {
    switch i {
        | 1 => "Feb"
        | 2 => "Mar"
        | 3 => "Apr"
        | 4 => "May"
        | 5 => "Jun"
        | 6 => "Jul"
        | 7 => "Aug"
        | 8 => "Sep"
        | 9 => "Oct"
        | 10 => "Nov"
        | 11 => "Dec"
        | _ => "Jan"
    }
}

let strToMonth = i => {
    switch i {
        | "Jan" => 0
        | "Feb" => 1
        | "Mar" => 2
        | "Apr" => 3
        | "May" => 4
        | "Jun" => 5
        | "Jul" => 6
        | "Aug" => 7
        | "Sep" => 8
        | "Oct" => 9
        | "Nov" => 10
        | _ => 11
    }
}

let rangeTypeOptions = [
    ("Range","Datetime range"),
    ("Last1Hour","Last 1 hour"),
    ("Last2Hours","Last 2 hours"),
    ("Last4Hours","Last 4 hours"),
    ("Last8Hours","Last 8 hours"),
    ("Last24Hours","Last 24 hours"),
    ("Today","Today"),
    ("Yesterday","Yesterday"),
    ("Last2Days","Last 2 days"),
    ("Last3Days","Last 3 days"),
    ("Last7Days","Last 7 days"),
]

let yearOptions = Belt_Array.range(2024-1,Date.now()->Date.fromTime->Date.getFullYear + 1)->Array.map(year => {
    (year->Int.toString, year->Int.toString)
})

let monthOptions = Belt_Array.range(0,11)->Array.map(i => {
    (i->monthToStr, i->monthToStr)
})

let hourOptions = Belt_Array.range(0,23)->Array.map(i => {
    (i->Int.toString, i->Int.toString)
})

let minuteOptions = Belt_Array.range(0,59)->Array.map(i => {
    (i->Int.toString, i->Int.toString)
})

let makeInitialState = (~initRange:option<timeRange>) => {
    {
        range: initRange->Option.getOr(Today),
    }
}

let setAfter = (st:state, after:option<Date.msSinceEpoch>):state => {
    switch st.range {
        | Range(_,before) => {range:Range(after,before)}
        | _ => st
    }
}

let setBefore = (st:state, before:option<Date.msSinceEpoch>):state => {
    switch st.range {
        | Range(after,_) => {range:Range(after,before)}
        | _ => st
    }
}

@react.component
let make = (
    ~label:string,
    ~initRange:option<timeRange>=?,
    ~onChange:timeRange=>unit,
) => {
    let (state, setState) = React.useState(() => makeInitialState(~initRange))

    React.useEffect1(() => {
        onChange(state.range)
        None
    }, [state.range])

    let rndSelect = (
        ~id:string, ~name:string, ~width:int, ~onChange:string=>unit, 
        ~options:array<(string,string)>, ~value:string,
        ~disabled:bool=false,
    ) => {
        <FormControl size=#small disabled>
            <InputLabel id>name</InputLabel>
            <Select
                sx={"width": width}
                labelId=id
                value=value
                label=name
                onChange=evt2str(onChange)
            >
                {
                    options->Array.map(((optionId,optionName)) => {
                        <MenuItem key=optionId value=optionId>{React.string(optionName)}</MenuItem>
                    })->React.array
                }
            </Select>
        </FormControl>
    }

    let rndTypeSelector = () => {
        rndSelect(
            ~id="rangeType", 
            ~name=label, 
            ~width=200, 
            ~onChange = newRangeType=>{
                setState(st => {
                    let newRange = switch strToTimeRange(newRangeType) {
                        | Range(_,_) => {
                            let (prevLeft,prevRight) = parseTimeRange(st.range, Date.now())
                            Range(prevLeft,prevRight)
                        }
                        | newRange => newRange
                    }
                    {range:newRange}
                })
            }, 
            ~options = rangeTypeOptions,
            ~value=state.range->timeRangeToStr
        )
    }

    let getDefaultTimeRangeBoundary = ():Date.msSinceEpoch => {
        let date = Date.make()
        let year = date->Date.getFullYear
        let month = date->Date.getMonth
        let day = date->Date.getDate
        Date.makeWithYMD(~year,~month,~date=day)->Date.getTime
    }

    let strToIntExn = str => str->Int.fromString->Option.getExn

    let getDaysInMonth = (year,month) => {
        Date.makeWithYMD(~year,~month=month+1,~date=0)->Date.getDate
    }

    let getDayOptions = (year,month) => {
        Belt_Array.range(1,getDaysInMonth(year,month))->Array.map(i => {
            (i->Int.toString, i->Int.toString)
        })
    }

    let rndBoundarySelector = (
        ~label:string, ~value:option<Date.msSinceEpoch>, ~onChange:option<Date.msSinceEpoch>=>unit,
        ~disabled:bool=false
    ) => {
        <Row>
            {
                <FormControlLabel
                    disabled
                    control={
                        <Checkbox
                            checked={value->Option.isSome}
                            onChange={evt2bool(checked => {
                                if checked {
                                    onChange(Some(getDefaultTimeRangeBoundary()))
                                } else {
                                    onChange(None)
                                }
                            })}
                        />
                    }
                    label
                />
            }
            {
                switch value {
                    | None => React.null
                    | Some(ms) => {
                        let date = Date.fromTime(ms)
                        let year = date->Date.getFullYear
                        let month = date->Date.getMonth
                        let day = date->Date.getDate
                        let hours = date->Date.getHours
                        let minutes = date->Date.getMinutes
                        <Row alignItems={#center}>
                            {rndSelect(
                                ~disabled,
                                ~id="year", 
                                ~name="Year", 
                                ~width=90, 
                                ~onChange = n=>onChange(Some(Date.makeWithYMDHM(
                                    ~year=n->strToIntExn,~month,~date=day,~hours,~minutes
                                )->Date.getTime)), 
                                ~options = yearOptions,
                                ~value=year->Int.toString
                            )}
                            {"-"->React.string}
                            {rndSelect(
                                ~disabled,
                                ~id="Month", 
                                ~name="Month", 
                                ~width=80, 
                                ~onChange = n=>onChange(Some(Date.makeWithYMDHM(
                                    ~year,~month=n->strToMonth,~date=day,~hours,~minutes
                                )->Date.getTime)), 
                                ~options = monthOptions,
                                ~value=month->monthToStr
                            )}
                            {"-"->React.string}
                            {rndSelect(
                                ~disabled,
                                ~id="Day", 
                                ~name="Day", 
                                ~width=70, 
                                ~onChange = n=>onChange(Some(Date.makeWithYMDHM(
                                    ~year,~month,~date=n->strToIntExn,~hours,~minutes
                                )->Date.getTime)), 
                                ~options = getDayOptions(year,month),
                                ~value=day->Int.toString
                            )}
                            {rndSelect(
                                ~disabled,
                                ~id="Hour", 
                                ~name="Hour", 
                                ~width=70, 
                                ~onChange = n=>onChange(Some(Date.makeWithYMDHM(
                                    ~year,~month,~date=day,~hours=n->strToIntExn,~minutes
                                )->Date.getTime)), 
                                ~options = hourOptions,
                                ~value=hours->Int.toString
                            )}
                            {":"->React.string}
                            {rndSelect(
                                ~disabled,
                                ~id="Minute", 
                                ~name="Minute", 
                                ~width=70, 
                                ~onChange = n=>onChange(Some(Date.makeWithYMDHM(
                                    ~year,~month,~date=day,~hours,~minutes=n->strToIntExn
                                )->Date.getTime)), 
                                ~options = minuteOptions,
                                ~value=minutes->Int.toString
                            )}
                        </Row>
                    }
                }
            }
        </Row>
    }

    let rndCustomRangeSelector = () => {
        switch state.range {
            | Range(after,before) => {
                <Col>
                    {
                        rndBoundarySelector(
                            ~label="After" ++ nbsp ++ nbsp ++ nbsp,
                            ~value=after,
                            ~onChange=newAfter=>setState(setAfter(_,newAfter))
                        )
                    }
                    {
                        rndBoundarySelector(
                            ~label="Before",
                            ~value=before,
                            ~onChange=newBefore=>setState(setBefore(_,newBefore))
                        )
                    }
                </Col>
            }
            | range => {
                let (after,before) = parseTimeRange(range, Date.now())
                <Col>
                    {
                        rndBoundarySelector(
                            ~label="After" ++ nbsp ++ nbsp ++ nbsp,
                            ~value=after,
                            ~onChange=_=>(),
                            ~disabled=true,
                        )
                    }
                    {
                        rndBoundarySelector(
                            ~label="Before",
                            ~value=before,
                            ~onChange=_=>(),
                            ~disabled=true,
                        )
                    }
                </Col>
            }
        }
    }

    <Paper style=ReactDOM.Style.make(~padding="5px", ())>
        <Col>
            {rndTypeSelector()}
            {rndCustomRangeSelector()}
        </Col>
    </Paper>
    
}
