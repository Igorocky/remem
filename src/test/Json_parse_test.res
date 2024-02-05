open Expln_test_utils
open Json_parse

let {log,log2} = module(Console)

describe("parseJson", () => {
    it("parses a simple object", () => {
        //given
        let jsonStr = `{
            "name": "AAA",
            "value": "BBB",
            "num": 123.4,
            "numOpt": null,
            "int": 78,
            "boolFalse": false,
            "boolTrue": true,
            "boolOpt": null
        }`

        //when
        let p = parseJson( jsonStr, toObj(_, o => 
            {
                "name": o->str("name"),
                "value": o->str("value"),
                "num": o->float("num"),
                "numOpt": o->floatOpt("numOpt"),
                "int": o->int("int"),
                "intOpt": o->intOpt("intOpt"),
                "boolFalse": o->bool("boolFalse"),
                "boolTrue": o->bool("boolTrue"),
                "boolOpt": o->boolOpt("boolOpt"),
            }
        ))

        //then
        switch p {
            | Ok(param) =>
                assertEq("AAA", param["name"])
                assertEq("BBB", param["value"])
                assertEq(123.4, param["num"])
                assertEq(None, param["numOpt"])
                assertEq(78, param["int"])
                assertEq(None, param["intOpt"])
                assertEq(false, param["boolFalse"])
                assertEq(true, param["boolTrue"])
                assertEq(None, param["boolOpt"])
            | Error(msg) => {
                log2("Error: ", msg)
                fail()
            }
        }
    })
    it("returns a meaningful message when null is passed", _ => {
        //given
        let jsonStr = `null`

        //when
        let p = parseJson( jsonStr, toObj(_, o => 
            {
                "name": o->str("name"),
                "value": o->str("value"),
            }
        ))

        //then
        switch p {
            | Error(msg) => assertEq(msg, "An object was expected at '/'.")
            | _ => fail()
        }
    })
    it("returns an error message when unparsable text is passed", _ => {
        //given
        let jsonStr = `null-`

        //when
        let p = parseJson( jsonStr, toObj(_, o => 
            {
                "name": o->str("name"),
                "value": o->str("value"),
            }
        ))

        //then
        switch p {
            | Error(msg) => assertEq(msg, "Unexpected non-whitespace character after JSON at position 4")
            | _ => fail()
        }
    })
    it("returns a meaningful message when null is passed for a non-null attribute", _ => {
        //given
        let jsonStr = `{
            "name": null,
            "value": "BBB"
        }`

        //when
        let p = parseJson( jsonStr, toObj(_, o => 
            {
                "name": o->str("name"),
                "value": o->str("value"),
            }
        ))

        //then
        switch p {
            | Error(msg) => assertEq(msg, "A string was expected at '/name'.")
            | _ => fail()
        }
    })
    it("returns a meaningful message when a non-null attribute is absent", _ => {
        //given
        let jsonStr = `{
            "name": "vvv"
        }`

        //when
        let p = parseJson( jsonStr, toObj(_, o => 
            {
                "name": o->str("name"),
                "value": o->str("value"),
            }
        ))

        //then
        switch p {
            | Error(msg) => assertEq(msg, "A string was expected at '/value'.")
            | _ => fail()
        }
    })
})

describe("toObjOpt", _ => {
    it("should return None when null is passed", _ => {
        //given
        let jsonStr = `null`

        //when
        let p = parseJson(jsonStr, toObjOpt(_, o => {
            "name": o->str("name"),
            "value": o->str("value"),
        }))

        //then
        assertEq(p, Ok(None))
    })
})

describe("strOpt", _ => {
    it("should return None when null is passed", _ => {
        //given
        let jsonStr = `{"arr":["A",null,"B"]}`

        //when
        let p = parseJson(jsonStr, toObj(_, o => 
            {
                "arr": o->arr("arr", toStrOpt(_)),
            }
        ))->Result.getExn

        //then
        assertEq(p, {"arr":[Some("A"),None,Some("B")]})
    })
    it("should return an error when null is passed", _ => {
        //given
        let jsonStr = `{"arr":["A",null,"B"]}`

        //when
        let p = parseJson(jsonStr, toObj(_, o => 
            {
                "arr": o->arr("arr", toStr(_)),
            }
        ))

        //then
        assertEq(p, Error("A string was expected at '/arr/1'."))
    })
})

describe("toFloatOpt", _ => {
    it("should return None when null is passed", _ => {
        //given
        let jsonStr = `{"arr":[23.8,null,41]}`

        //when
        let p = parseJson(jsonStr, toObj(_, o => {
            "arr": o->arr("arr", toFloatOpt(_)),
        }))->Belt_Result.getExn

        //then
        assertEq(p, {"arr":[Some(23.8),None,Some(41.)]})
    })
})

describe("toFloat", _ => {
    it("should return an error when null is passed", _ => {
        //given
        let jsonStr = `{"arr":[23.8,null,41]}`

        //when
        let p = parseJson(jsonStr, toObj(_, o => {
            "arr": o->arr("arr", toFloat(_)),
        }))

        //then
        assertEq(p, Error("A number was expected at '/arr/1'."))
    })
})

describe("toIntOpt", _ => {
    it("should return None when null is passed", _ => {
        //given
        let jsonStr = `{"arr":[23.8,null,41]}`

        //when
        let p = parseJson(jsonStr, toObj(_, o => {
            "arr": o->arr("arr", toIntOpt(_)),
        }))->Belt_Result.getExn

        //then
        assertEq(p, {"arr":[Some(23),None,Some(41)]})
    })
})

describe("toInt", _ => {
    it("should return an error when null is passed", _ => {
        //given
        let jsonStr = `{"arr":[23.8,null,41]}`

        //when
        let p = parseJson(jsonStr, toObj(_, o => {
            "arr": o->arr("arr", toInt(_)),
        }))

        //then
        assertEq(p, Error("An integer was expected at '/arr/1'."))
    })
})

describe("toBoolOpt", _ => {
    it("should return None when null is passed", _ => {
        //given
        let jsonStr = `{"arr":[true,null,false]}`

        //when
        let p = parseJson(jsonStr, toObj(_, o => {
            "arr": o->arr("arr", toBoolOpt(_)),
        }))->Belt_Result.getExn

        //then
        assertEq(p, {"arr":[Some(true),None,Some(false)]})
    })
})

describe("toBool", _ => {
    it("should return an error when null is passed", _ => {
        //given
        let jsonStr = `{"arr":[true,null,false]}`

        //when
        let p = parseJson(jsonStr, toObj(_, o => {
            "arr": o->arr("arr", toBool(_)),
        }))

        //then
        assertEq(p, Error("A boolean was expected at '/arr/1'."))
    })
})
