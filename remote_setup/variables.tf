#############################################################################
# VARIABLES
#############################################################################

variable "location" {
  type    = string
  default = "eastus"
}

variable "naming_prefix" {
  type    = string
  default = "ghlabs"
}

variable "github_repository" {
  type    = string
  default = "terraform-azure-infra"
}