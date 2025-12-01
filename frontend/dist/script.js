// backendUrl debe declararse en config.js

const BackendStatusModule = () => {
    const backendRefreshButton = document.querySelector('#backendrefresh')
    const backendErrorDiv = document.querySelector('#backenderror')

    const serviceStatusDiv = document.querySelector('#status')
    const propiedadesStatusDiv = document.querySelector('#propiedades-status')
    const reservasStatusDiv = document.querySelector('#reservas-status')
    
    const serviceRefresh = async (url, statusDiv) => {
        const res = await fetch(url)
        const body = await res.json()
        statusDiv.textContent = `task_identifier: ${body.task_identifier}`
    }

    const backendRefresh = async (evt) => {
        try {
            evt.target.disabled = true
            serviceStatusDiv.display = 'none'
            backendErrorDiv.style.display = 'none'

            const propPromise = serviceRefresh(`${backendUrl}/propiedades/status`, propiedadesStatusDiv)
            const resPromise = serviceRefresh(`${backendUrl}/reservas/status`, reservasStatusDiv)

            await Promise.all([ propPromise, resPromise ])
            serviceStatusDiv.style.display = 'block'

        } catch(err) {
            backendErrorDiv.style.display = 'block'
            backendErrorDiv.textContent = `${err}`
        } finally {
            evt.target.disabled = false
        }
    }

    backendRefreshButton.addEventListener('click', backendRefresh)
}

const DialogModule = () => {
    const dialog = document.querySelector('#dialog')
    const dialogSubmitButton = document.querySelector('#dialogsubmit')
    const reservaForm = document.forms['reservaform']

    const open = (propiedadId) => {
        reservaForm.elements.propiedadid.value = propiedadId
        dialog.showModal()
    }

    const submit = async (evt) => {
        try {
            evt.preventDefault()
            dialogSubmitButton.disabled = true

            const dummyRequest = {
                guestname: 'dummyName',
                arrivaltime: Date.now(),
                numguests: 5,
                propiedadId: reservaForm.elements.propiedadid.value,
                email: reservaForm.elements.email.value
            }

            await fetch(`${backendUrl}/reservas`, {
                method: 'POST',
                body: JSON.stringify(dummyRequest),
                headers: {
                    'Content-Type': 'application/json'
                }
            })

            alert('Reserva realizada! Revisa tu correo!')
            dialogSubmitButton.disable = false
            reservaForm.elements.propiedadid.value = ''
        } catch(err) {
            alert(`${err}`)
        } finally {
            dialog.close()
        }
    }

    reservaForm.addEventListener('submit', submit)

    return { open }
}

const TablaPropiedadesModule = (dialogModule) => {
    const tableRefreshButton = document.querySelector('#tablarefresh')
    const poblarButton = document.querySelector('#poblar')
    const tableErrorDiv = document.querySelector('#tableerror')
    const tableBody = document.querySelector('#tablebody')

    const getTdFromAttrib = (value) => {
        const td = document.createElement('td')
        td.textContent = value
        return td
    }

    const getTableRowsFromData = (data) => {
        return data.map((elem) => {
            const row = document.createElement('tr')

            const maxGuests = getTdFromAttrib(elem['maxguests'])
            const propiedadId = getTdFromAttrib(elem['PropiedadID'])
            const owner = getTdFromAttrib(elem['owner'])
            const fechaRegistro = getTdFromAttrib(elem['FechaRegistro'])
            const dir = getTdFromAttrib(elem['dir'])
            const type = getTdFromAttrib(elem['type'])
            const state = getTdFromAttrib(elem['state'])
            const nroClientes = getTdFromAttrib(!elem.numeroClientes ? '-' : '' + elem.numeroClientes)

            const btn = document.createElement('button')
            btn.textContent = 'Reservar'
            btn.setAttribute('data-prop-id', elem['PropiedadID'])
            const btnTd = document.createElement('td')
            btnTd.appendChild(btn)

            row.append(
                propiedadId,
                type,
                state,
                dir,
                owner,
                maxGuests,
                nroClientes,
                fechaRegistro,
                btnTd
            )

            return row
        })
    }

    const tableRefresh = async (evt) => {
        try {
            evt.target.disabled = true
            tableErrorDiv.style.display = 'none'

            while(tableBody.hasChildNodes()) {
                tableBody.removeChild(tableBody.lastChild)
            }

            const res = await fetch(`${backendUrl}/propiedades`)
            const { data } = await res.json()

            const rows = getTableRowsFromData(data)
            tableBody.append(...rows)
        } catch(err) {
            tableErrorDiv.style.display = 'block'
            tableErrorDiv.textContent = `${err}`
        } finally {
            evt.target.disabled = false
        }
    }

    const propiedadesDummies = [
        {
            type: 'Casa',
            state: 'Disponible',
            dir: 'Calle Luna 123, Madrid',
            owner: 'Carlos Gómez',
            maxguests: 4
        },
        {
            type: 'Apartamento',
            state: 'Ocupado',
            dir: 'Av. del Sol 45, Barcelona',
            owner: 'María Pérez',
            maxguests: 2
        },
        {
            type: 'Cabaña',
            state: 'Disponible',
            dir: 'Bosque Verde 78, Asturias',
            owner: 'Lucía Fernández',
            maxguests: 6
        },
        {
            type: 'Estudio',
            state: 'Mantenimiento',
            dir: 'Centro Histórico 12, Sevilla',
            owner: 'Javier Ruiz',
            maxguests: 1
        },
        {
            type: 'Villa',
            state: 'Disponible',
            dir: 'Costa Azul 99, Valencia',
            owner: 'Ana Torres',
            maxguests: 8
        }
    ]

    const populate = async (evt) => {
        try {
            evt.target.disabled = true
            tableErrorDiv.style.display = 'none'

            const promises = []

            propiedadesDummies.forEach(el => {
                const req = fetch(`${backendUrl}/propiedades`, {
                    method: 'POST',
                    body: JSON.stringify(el),
                    headers: {
                        'Content-Type': 'application/json'
                    }
                })
                promises.push(req)
            })

            await Promise.all(promises)
            alert('Registros realizados correctamente')

        } catch(err) {
            tableErrorDiv.style.display = 'block'
            tableErrorDiv.textContent = `${err}`
        } finally {
            evt.target.disabled = false
        }
    }


    const tableClick = (evt) => {
        if (evt.target.tagName === 'BUTTON') {
            dialogModule.open(evt.target.getAttribute('data-prop-id'))
        }
    }
    
    tableRefreshButton.addEventListener('click', tableRefresh)
    poblarButton.addEventListener('click', populate)
    tableBody.addEventListener('click', tableClick)
}

const Dialog = DialogModule()
BackendStatusModule()
TablaPropiedadesModule(Dialog)