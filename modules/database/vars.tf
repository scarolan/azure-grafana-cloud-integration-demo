variable "primary_database" {}
variable "resource_group" {}
variable "location" {}
variable "primary_database_version" {}
variable "primary_database_admin" {}
variable "primary_database_password" {}
variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
  default     = {}
}

