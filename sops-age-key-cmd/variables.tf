variable "age_command" {
  type        = string
  default     = "keepassxc-kph --rows=password --plain age://%s"
  description = "Get Age private key from external secrets store by exec command"
}
