import { DynamoDBClient } from "@aws-sdk/client-dynamodb"
import { DynamoDBDocumentClient, UpdateCommand } from "@aws-sdk/lib-dynamodb"

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }))

export const handler = async (event) => {
    for (const record of event.Records) {
        const message = JSON.parse(JSON.parse(JSON.parse(record.body).Message))

        const propiedadId = message.propiedadId

        if (!propiedadId) {
            console.error("Mensaje incompleto")
            continue
        }

        try {
            const cmd = new UpdateCommand({
                TableName: "Propiedades",
                Key: {
                    PropiedadID: "" + propiedadId
                },
                UpdateExpression: "ADD numeroClientes :inc",
                ExpressionAttributeValues: {
                    ":inc": 1
                },
                ReturnValues: "UPDATED_NEW"
            })

            const resp = await ddb.send(cmd)

            console.log(`Propiedad ${propiedadId} actualizada:`)

        } catch (err) {
            console.error(`Error actualizando propiedad ${propiedadId}:`, err)
        }
    }

    return { status: "ok" }
};
