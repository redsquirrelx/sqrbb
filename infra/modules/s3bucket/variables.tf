variable "region" {
    
}

variable "bucket_name" {
  
}

variable "enable_access_logs" {
    type = bool
}

variable "bucket_access_logs_bucket" {
    nullable = true
    default = null
}

variable "replicate" {
    type = bool
}

variable "bucket_replicated_id" {
    nullable = true
    default = null
}

variable "enable_event_notifs" {
    type = bool
}

variable "sns_arn" {
    nullable = true
    default = null
}