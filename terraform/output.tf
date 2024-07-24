output "resource_group_name" {
  description = "The name of the created resource group."
  value       = azurerm_resource_group.tj_rg.name
}

output "virtual_network_name" {
  description = "The name of the created virtual network."
  value       = azurerm_virtual_network.tj.name
}

output "subnet_name_1" {
  description = "The name of the created subnet 1."
  value       = azurerm_subnet.tj1_subnet.name
}

output "subnet_name_2" {
  description = "The name of the created subnet 2."
  value       = azurerm_subnet.tj2_subnet.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.tj_vm
  sensitive = true
}

output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}