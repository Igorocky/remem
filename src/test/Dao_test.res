open Expln_test_utils
open Dao

let {log,log2} = module(Console)

describe("Dao:tags", () => {
    it("creates new tags", () => {
        //given
        let db = Sqlite.makeDatabase(":memory:")
        Dao.initDatabase(db)

        //when
        let allTags = db->createTag({name:"test-tag-1"})

        //then
        assertEq(allTags, {tags:[{id:"1",name:"test-tag-1"}]})

        //when
        let allTags = db->createTag({name:"test-tag-2"})

        //then
        assertEq(allTags, {tags:[{id:"1",name:"test-tag-1"},{id:"2",name:"test-tag-2"}]})

        //when
        let allTags = db->createTag({name:"test-tag-3"})

        //then
        assertEq(allTags, {tags:[{id:"1",name:"test-tag-1"},{id:"2",name:"test-tag-2"},{id:"3",name:"test-tag-3"}]})
    })

    it("deletes existing tags", () => {
        //given
        let db = Sqlite.makeDatabase(":memory:")
        Dao.initDatabase(db)
        db->createTag({name:"test-tag-1"})->ignore
        db->createTag({name:"test-tag-2"})->ignore
        let allTags = db->createTag({name:"test-tag-3"})
        assertEqMsg(
            allTags, 
            {tags:[{id:"1",name:"test-tag-1"},{id:"2",name:"test-tag-2"},{id:"3",name:"test-tag-3"}]},
            "prepare test data"
        )

        //when
        let allTags = db->deleteTags({ids:["1","3"]})

        //then
        assertEqMsg(allTags, {tags:[{id:"2",name:"test-tag-2"}]}, "after delete")
    })

    it("updates existing tag", () => {
        //given
        let db = Sqlite.makeDatabase(":memory:")
        Dao.initDatabase(db)
        db->createTag({name:"test-tag-1"})->ignore
        db->createTag({name:"test-tag-2"})->ignore
        let allTags = db->createTag({name:"test-tag-3"})
        assertEqMsg(
            allTags, 
            {tags:[{id:"1",name:"test-tag-1"},{id:"2",name:"test-tag-2"},{id:"3",name:"test-tag-3"}]},
            "prepare test data"
        )

        //when
        let allTags = db->updateTag({id:"2", name:"updated-name"})

        //then
        assertEqMsg(
            allTags, 
            {tags:[{id:"1",name:"test-tag-1"},{id:"3",name:"test-tag-3"},{id:"2",name:"updated-name"}]},
            "after update"
        )
    })

    it("creates new cards", () => {
        //given
        let db = Sqlite.makeDatabase(":memory:")
        Dao.initDatabase(db)
        db->Dao.fillDbWithRandomData(
            ~numOfTags=2,
            ~numOfCardsOfEachType=2,
            ~minNumOfTagsPerCard=0,
            ~maxNumOfTagsPerCard=2,
            ~histLengthPerTask=1,
            ~markProbs=[(0.,1),(1.,1)],
        )

        //when
        let allCards = db->findCards({})

        //then
        assertEq( allCards->Array.length, 2 )
    })
})
