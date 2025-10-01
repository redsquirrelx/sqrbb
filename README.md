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