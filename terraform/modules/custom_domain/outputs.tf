output "custom_domain_name" {
  value = var.domain_name
}

output "custom_invoke_base_url" {
  value = "https://${var.domain_name}"
}
