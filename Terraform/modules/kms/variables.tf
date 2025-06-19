variable "deletion_window_in_days" {
    type = number
    default = 7
}

variable "enable_key_rotation" {
    type = bool
    default = true
}

variable "project_name" {
    type = string
}

variable "environment" {
    type = string
}