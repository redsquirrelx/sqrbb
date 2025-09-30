const { randomUUID } = require('crypto')
const express = require('express')
const app = express()

const task_identifier = randomUUID()

app.get('/reservas', (req, res) => {
    res.json({
        task_identifier,
        msg: "msrvc-reservas"
    })
})

app.listen(80, () => {
    console.log("listening", 80)
})