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

# Arquitectura
<img width="5217" height="3009" alt="Diagrama IaC - Página 1" src="https://github.com/user-attachments/assets/d1256bea-1b51-445a-871b-c02736e57b07" />

# Uso
1. Configurar aws-cli con las credenciales de una cuenta AWS
```
aws configure
```

2. Configurar dos repositorios en ECR con las aplicaciones en `services/`:
- microservices/propiedades
- microservices/reservas

3. Clonar el repositorio:
```
git clone https://github.com/redsquirrelx/sqrbb.git
cd sqrbb
```

4. Levantar arquitectura:
```
sudo terraform -chdir=infra/ init
sudo terraform -chdir=infra/ apply
```
Solicitará un código de cuenta de AWS.

5. Desplegar front end
```
sudo ansible-playbook -i config/inventory.ini config/desplegar-frontend.yaml
```
