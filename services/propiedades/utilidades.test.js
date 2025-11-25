const { validarCamposRegistroPropiedad, validarPropiedad } = require('./utilidades')

describe('validarCamposRegistroPropiedad', () => {
    test('debe retornar falso si falta algun campo requerido', () => {
        const body = {
            type: 'casa',
            state: 'disponible',
            dir: 'calle 123',
            owner: 'Juan'
            // falta maxguests
        }

        expect(validarCamposRegistroPropiedad(body)).toBeFalsy()
    })

    test('debe retornar true si todos los campos están presentes', () => {
        const body = {
            type: 'casa',
            state: 'disponible',
            dir: 'calle 123',
            owner: 'Juan',
            maxguests: 4
        }

        expect(validarCamposRegistroPropiedad(body)).toBeTruthy()
    })
})

describe('validarPropiedad', () => {
    test('debe retornar true si maxguests es mayor que 0', () => {
        const body = { maxguests: 3 }
        expect(validarPropiedad(body)).toBe(true)
    })

    test('debe retornar false si maxguests es 0', () => {
        const body = { maxguests: 0 }
        expect(validarPropiedad(body)).toBe(false)
    })

    test('debe retornar false si maxguests es negativo', () => {
        const body = { maxguests: -5 }
        expect(validarPropiedad(body)).toBe(false)
    })
})