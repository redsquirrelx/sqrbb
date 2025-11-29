import { SESClient, SendEmailCommand, ListIdentitiesCommand } from "@aws-sdk/client-ses"

const ses = new SESClient({ region: process.env.AWS_REGION })

export const handler = async (event) => {
  try {
    for (const record of event.Records) {
      const body = JSON.parse(JSON.parse(JSON.parse(record.body).Message))

      const message = {
        propiedadId: body.propiedadId,
        timestamp: (new Date(body.timestamp)).toString(),
        arrival: body.arrival,
        email: body.email
      }

      console.log("Procesando mensaje para propiedad:", message.propiedadId)
      console.log("sender:", process.env.SES_SENDER_EMAIL)

      // Construcción del cuerpo del correo
      const emailParams = {
        Destination: {
          ToAddresses: [message.email],
        },
        Message: {
          Subject: { Data: `Información sobre la propiedad ${message.propiedadId}` },
          Body: {
            Text: {
              Data:
                `Hola,\n\n` +
                `Recibimos tu solicitud sobre la propiedad ${message.propiedadId}.\n` +
                `Hora de llegada: ${message.arrival}\n` +
                `Timestamp recibido: ${message.timestamp}\n\n` +
                `Gracias.`
            }
          }
        },
        Source: process.env.SES_SENDER_EMAIL,
      }

      const emailCmd = new SendEmailCommand(emailParams)
      await ses.send(emailCmd)
      console.log(`Correo enviado a ${message.email}`)
    }

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Mensajes procesados correctamente" }),
    }

  } catch (err) {
    console.error("Error procesando mensajes:", err)
    throw err
  }
}
