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
                body: dummyRequest
            })

            alert('Reserva realizada! Revisa tu correo!')
        } catch(err) {
            alert(`${err}`)
        } finally {
            dialog.close()
        }
    }

    reservaForm.addEventListener('submit', submit)

    return { open }
}

BackendStatusModule()