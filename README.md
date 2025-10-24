# Infraestructura para un sistema de reservas de alojamientos

Integrantes:
- Aguilar Chavez Fabricio 
- Melendez Quezada Fabricio
- Muga Ponce Franco 
- Quispe Cesias Andro 
- Rodriguez Acevedo Emerson 

## Problema
El sistema actual de reservas de alojamientos colapsa en picos de concurrencia, saturando colas/BD y degradando disponibilidad por infraestructura no estandarizada y difícil de recuperar.

## Descripción del proyecto
El sistema se despliega en AWS bajo la arquitectura de microservicios, la infraestructura se gestiona con Terraform y cada servicio se empaqueta y ejecuta en contenedores Docker.

## Requisitos previos
- Terraform >= v1.13.1
- Docker >= 28.4.0
- Ansible >= 2.18.9
- aws-cli >= 2.30.1
- node >= 22.x

# Arquitectura
Se aspira a lo siguiente:
<img width="6755" height="4037" alt="Diagrama IaC - Página 1 (3)" src="https://github.com/user-attachments/assets/4a2fbc88-54cf-4076-ad1e-63efaa76591c" />


# Uso
1. Configurar aws-cli con las credenciales de una cuenta AWS
```
aws configure
```

2. Clonar el repositorio:
```
git clone https://github.com/redsquirrelx/sqrbb.git
cd sqrbb
```

3. Levantar arquitectura:
```
terraform -chdir=infra/ init
terraform -chdir=infra/ apply
```

4. Crear un archivo ``desplegar.json`` con el contenido, dentro de la carpeta ``config/``:
```json
{
  "microservicios": [
    {
      "name": "propiedades",
      "root": "services/propiedades"
    },
    {
      "name": "reservas",
      "root": "services/reservas"
    }
  ]
}
```
5. Desplegar microservicios:
```bash
ansible-playbook -i config/inventory.ini config/despl-microservicios.yaml -e "@config/desplegar.json"
```
5. Desplegar lambda "sigv4a"
```bash
ansible-playbook -i config/inventory.ini config/despl-lambdafn-sigv4a.yaml
```

6. Desplegar front end
```bash
ansible-playbook -i config/inventory.ini config/despl-frontend.yaml
```
7. Desplegar API Gateway en la consola AWS (temporal)