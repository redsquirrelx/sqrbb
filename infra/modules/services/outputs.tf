output "cluster-main" {
    value = aws_ecs_cluster.this
}

output "propiedades_td_arn" {
    value = module.propiedades.task_definition_arn
}

output "reservas_td_arn" {
    value = module.reservas.task_definition_arn
}