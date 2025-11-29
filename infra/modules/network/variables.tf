variable "flow_log_group_arn" {}

variable "enviar_correo_sg_id" {
    nullable = true
    default = null
}

variable "actualizar_estadisticas_sg_id" {
    nullable = true
    default = null
}

variable "region" {}