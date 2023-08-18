# Best practice: include the variable type.

# Without a default value, you'll be asked to provide a value
# for your variables whenever using terraform apply command.
variable "host_os" {
  type    = string
  default = "windows"
}