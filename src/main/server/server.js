import express from "express";
import {makeBackend} from './App_config.res.mjs'
const app = express()
const port = 3000

const backend = makeBackend()

app.use(express.json({limit:'10MB'}))

app.post('/be/:funcName', async (req, res) => {
    const funcName = req.params.funcName
    res.send(await backend.execBeFunc(funcName, req.body))
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})