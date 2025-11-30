const { randomUUID } = require('crypto')
const express = require('express')
const app = express()
const cors = require('cors')

const { DynamoDBClient } = require('@aws-sdk/client-dynamodb')
const { DynamoDBDocumentClient, PutCommand, ScanCommand } = require('@aws-sdk/lib-dynamodb')

const task_identifier = `${randomUUID()}-${process.env.SERVICE_REGION}`
const client = new DynamoDBClient({ region: process.env.SERVICE_REGION })
const dbClient = DynamoDBDocumentClient.from(client)

const { validarCamposRegistroPropiedad, validarPropiedad } = require('./utilidades')

app.use(cors({
    origin: `https://${process.env.DOMAIN_NAME}`,
    methods: [ 'GET', 'POST' ]
}))

app.use(express.json())

app.get('/propiedades/status', (req, res) => {
    res.json({
        task_identifier,
        msg: `msrvc-propiedades`
    })
})

app.get('/propiedades', (req, res) => {
    const cmd = new ScanCommand({
        TableName: "Propiedades"
    })

    dbClient.send(cmd).then(r => {
        res.json({
            task_identifier,
            msg: `msrvc-propiedades-${process.env.SERVICE_REGION}`,
            data: r.Items
        })
    }).catch(err => {
        res.json({
            task_identifier,
            msg: `msrvc-propiedades-${process.env.SERVICE_REGION}`,
            err
        })
    })
})

app.post('/propiedades', (req, res) => {
    if (!validarCamposRegistroPropiedad(req.body)) {
        res.status(400)
        return res.json({
            task_identifier,
            msg: "bad request: faltan campos obligatorios"
        })
    }

    if (!validarPropiedad(req.body)) {
        res.status(400)
        return res.json({
            task_identifier,
            msg: "bad request: nro. de huespedes invalido"
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