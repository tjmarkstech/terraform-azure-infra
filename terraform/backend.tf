terraform {
  backend "azurerm" {
    resource_group_name  = "github_action_rg"  # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
    storage_account_name = "terraformgithub1"                      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "terraform-container"                       # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "tj.tfstate"        # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}