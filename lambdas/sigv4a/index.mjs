import { sigV4ASignBasic } from "./sigv4a_sign.js"

export const handler = async (event, context, callback) => {
    const request = event.Records[0].cf.request

    const { method, uri } = request
    const domainName = request.origin.custom.domainName
    const endpoint = `https://${domainName}${uri}`
    console.log("Endpoint: ", endpoint)
    console.log("Headers: ", request.headers)

    // Firmar
    const signedHeadersCRT = sigV4ASignBasic(method, endpoint, "s3")

    const cfHeaders = {}
    for (const [k, v] of signedHeadersCRT._flatten()) {
        //cfHeaders[k.toLowerCase()] = [{ key: k, value: v }]
        const key = k.toLowerCase();
        if (["host", "connection", "upgrade", "via"].includes(key)) continue;
        cfHeaders[key] = [{ key: k, value: v }];
    }

    // Mantener host original
    cfHeaders["host"] = request.headers["host"];

    // Agregar headers firmados
    request.headers = { ...request.headers, ...cfHeaders };

    console.log("Signed request:", JSON.stringify(request))
    return callback(null, request)
}