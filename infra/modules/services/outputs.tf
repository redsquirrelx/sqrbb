output "cluster-main" {
    value = aws_ecs_cluster.this
}

output "propiedades_td_arn" {
    value = aws_ecs_task_definition.this["propiedades"].arn
}

output "reservas_td_arn" {
    value = aws_ecs_task_definition.this["reservas"].arn
}