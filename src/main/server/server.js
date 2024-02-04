import express from "express";
import {execBeMethod} from './Endpoints.res.mjs'
import * as dao from './Dao.res.mjs'
const app = express()
const port = 3000

app.use(express.json({limit:'10MB'}))

app.post('/be/:methodName', async (req, res) => {
    const methodName = req.params.methodName
    console.log('methodName', methodName)
    console.log('req.body', req.body)
    res.send(await execBeMethod(methodName, req.body))
})

dao.initDatabase()

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})