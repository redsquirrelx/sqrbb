const { randomUUID } = require('crypto')
const express = require('express')
const app = express()

const { validarCamposReserva, validarReserva } = require('./utilidades')

const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns')

const snsClient = new SNSClient({ region: process.env.SERVICE_REGION })

const task_identifier = `${randomUUID()}-${process.env.SERVICE_REGION}`

app.use(express.json())

app.get('/reservas/status', (req, res) => {
    res.json({
        task_identifier,
        msg: `msrvc-reservas`
    })
})

app.post('/reservas', (req, res) => {
    if (!validarCamposReserva(req.body)) {
        res.status(400)
        return res.json({
            task_identifier,
            msg: "bad request: faltan campos obligatorios"
        })
    }

    if (!validarReserva(req.body)) {
        res.status(400)
        return res.json({
            task_identifier,
            msg: "bad request: datos incorrectos"
        })
    }

    const message = {
        propiedadId: req.body.propiedadId,
        timestamp: Date.now(),
        arrival: req.body.arrivaltime,
        email: req.body.email
    }

    const pubCmd = new PublishCommand({
        Message: JSON.stringify(message),
        TopicArn: process.env.RESERVAS_PROC_SNS_TOPIC_ARN
    })

    snsClient.send(pubCmd).then(r => {
        res.json({
            task_identifier,
            msg: "Reserva realizada -> " + JSON.stringify(r)
        })
    }).catch(err => {
        res.status(500).json({
            task_identifier,
            msg: "error -> " + JSON.stringify(err)
        })
    })
})

app.listen(80, () => {
    console.log("listening", 80)
})