const { randomUUID } = require('crypto')
const express = require('express')
const app = express()

const { DynamoDBClient } = require('@aws-sdk/client-dynamodb')
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb')

const task_identifier = randomUUID()
const client = new DynamoDBClient({ region: "us-east-2" })
const dbClient = DynamoDBDocumentClient.from(client)

app.use(express.json())

app.get('/propiedades', (req, res) => {
    res.json({
        task_identifier,
        msg: "msrvc-propiedades"
    })
})

app.post('/propiedades', (req, res) => {
    if (!req.body.type || !req.body.state || !req.body.dir || !req.body.owner) {
        res.status(400)
        return res.json({
            task_identifier,
            msg: "bad request"
        })
    }

    const formData = req.body

    const now = Date.now()

    const command = new PutCommand({
        TableName: "Propiedades",
        Item: {
            PropiedadID: randomUUID(),
            FechaRegistro: now,
            ...formData
        }
    })

    dbClient.send(command).then(r => {
        res.json({
            task_identifier,
            msg: "IT WORKED! :D ->" + r
        })
    }).catch(err => {
        res.status(500).json({
            task_identifier,
            msg: "error -> " + err
        })
    })
})

app.listen(80, () => {
    console.log("listening", 80)
})