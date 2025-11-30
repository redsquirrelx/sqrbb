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

## Requisitos
- Docker >= 28.4.0

# Arquitectura
Se aspira a lo siguiente:
<img width="6755" height="4037" alt="Diagrama IaC - Página 1 (3)" src="https://github.com/user-attachments/assets/4a2fbc88-54cf-4076-ad1e-63efaa76591c" />


# Uso

## 1. Clonar el repositorio
```bash
git clone https://github.com/redsquirrelx/sqrbb.git
cd sqrbb
```

## 2. Ingresar variables de entorno (.env)
```bash
cp .env.template .env
```

## 3. Levantar Jenkins
```bash
docker compose up -d
```

## 5. Ejecutar jobs
* Iniciar primero el pipeline de provisionamiento