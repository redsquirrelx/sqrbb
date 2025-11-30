const utilidades = require('./utilidades')

describe('validarCamposReserva', () => {
    test('debe retornar true si todos los campos existen', () => {
        const body = {
            propiedadId: '123',
            guestname: 'Juan',
            email: 'correo@test.com',
            numguests: 2,
            arrivaltime: '10:00'
        }

        expect(utilidades.validarCamposReserva(body)).toBeTruthy()
    })

    test('debe retornar false si falta algún campo', () => {
        const body = {
            propiedadId: '123',
            guestname: 'Juan',
            email: 'correo@test.com',
            // falta numguests
            arrivaltime: '10:00'
        }

        expect(utilidades.validarCamposReserva(body)).toBeFalsy()
    })
})

describe('validarReserva', () => {
    test('debe retornar true si numguests > 0 y el email es válido', () => {
        const body = {
            numguests: 3,
            email: 'test@correo.com'
        }

        expect(utilidades.validarReserva(body)).toBeTruthy()
    })

    test('debe retornar false si numguests <= 0', () => {
        const body = {
            numguests: 0,
            email: 'test@correo.com'
        }

        expect(utilidades.validarReserva(body)).toBeFalsy()
    })

    test('debe retornar false si el email es inválido', () => {
        const body = {
            numguests: 2,
            email: 'email-malo'
        }

        expect(utilidades.validarReserva(body)).toBeFalsy()
    })
})