module.exports = {
    validarCamposRegistroPropiedad: (body) => {
        return body.type && body.state && body.dir && body.owner && body.maxguests
    },
    validarPropiedad: (body) => {
        return body.maxguests > 0
    }
}