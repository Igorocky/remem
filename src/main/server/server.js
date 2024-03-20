import express from 'express'
import {makeBackend} from './App_config.res.mjs'
import fs from 'fs'

const config = JSON.parse(fs.readFileSync('app-config.json', 'utf8'));
console.log("config = " + JSON.stringify(config));

const app = express()
const port = 3000

const backend = makeBackend({dbFilePath:config.database.filePath})

app.use(express.json({limit:'10MB'}))
app.use(express.static("ui"))

app.post('/be/:funcName', async (req, res) => {
    const funcName = req.params.funcName
    try {
        res.send(await backend.execBeFunc(funcName, req.body))
    } catch (ex) {
        res.send(JSON.stringify({err:ex.message}))
    }
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})