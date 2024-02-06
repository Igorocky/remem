open Expln_test_utils
open Dao

let {log,log2} = module(Console)

describe("Dao:tags", () => {
    itAsync("creates new tags", async () => {
        //given
        let db = Sqlite.makeDatabase(":memory:")
        Dao.initDatabase(db)

        //when
        let allTags = await db->createTag({name:"test-tag-1"})

        //then
        assertEq(allTags, {tags:[{id:1.,name:"test-tag-1"}]})

        //when
        let allTags = await db->createTag({name:"test-tag-2"})

        //then
        assertEq(allTags, {tags:[{id:1.,name:"test-tag-1"},{id:2.,name:"test-tag-2"}]})

        //when
        let allTags = await db->createTag({name:"test-tag-3"})

        //then
        assertEq(allTags, {tags:[{id:1.,name:"test-tag-1"},{id:2.,name:"test-tag-2"},{id:3.,name:"test-tag-3"}]})
    })

    itAsync("deletes existing tags", async () => {
        //given
        let db = Sqlite.makeDatabase(":memory:")
        Dao.initDatabase(db)
        (await db->createTag({name:"test-tag-1"}))->ignore
        (await db->createTag({name:"test-tag-2"}))->ignore
        let allTags = await db->createTag({name:"test-tag-3"})
        assertEqMsg(
            allTags, 
            {tags:[{id:1.,name:"test-tag-1"},{id:2.,name:"test-tag-2"},{id:3.,name:"test-tag-3"}]},
            "prepare test data"
        )

        //when
        let allTags = await db->deleteTags({ids:[1.,3.]})

        //then
        assertEq(allTags, {tags:[{id:2.,name:"test-tag-2"}]})
    })
})