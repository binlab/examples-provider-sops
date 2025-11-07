variable "age_command" {
  type        = string
  default     = "keepassxc-kph --rows=password age://%s"
  description = "Get Age private key from external secrets store by exec command"
}
