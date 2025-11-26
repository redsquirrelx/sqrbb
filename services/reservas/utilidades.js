const validator = require('email-validator')

module.exports = {
    validarCamposReserva: (body) => {
        return body.propiedadId && body.guestname && body.email && body.numguests && body.arrivaltime
    },
    validarReserva: (body) => {
        return body.numguests > 0 && validator.validate(body.email)
    }
}