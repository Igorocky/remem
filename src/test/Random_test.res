open Expln_test_utils

let {log,log2} = module(Console)

describe("randSelect", () => {
    it("respects provided probabilities", () => {
        //given
        let samples = [(0,3),(1,1),(2,0),(3,2)]
        let counts = Array.make(~length=4,0)

        //when
        for _ in 1 to 100_000 {
            let idx = Random.randSelect(samples)
            counts[idx] = counts->Array.getUnsafe(idx) + 1
        }

        //then
        let cntSum = counts->Array.reduce(0,(a,b)=>a+b)->Float.fromInt
        let probSum = 6.0
        assertEqNum(counts->Array.getUnsafe(0)->Int.toFloat /. cntSum, 3.0 /. probSum, 0.01)
        assertEqNum(counts->Array.getUnsafe(1)->Int.toFloat /. cntSum, 1.0 /. probSum, 0.01)
        assertEqNum(counts->Array.getUnsafe(2)->Int.toFloat /. cntSum, 0.0, 0.01)
        assertEqNum(counts->Array.getUnsafe(3)->Int.toFloat /. cntSum, 2.0 /. probSum, 0.01)
    })
})
