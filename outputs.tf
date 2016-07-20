output "vpn_endpoint_id" { value = "${aws_instance.vpn_endpoint.id}" }
output "vpn_endpoint_public_ip" { value = "${aws_instance.vpn_endpoint.public_ip}" }
output "vpn_endpoint_private_ip" { value = "${aws_instance.vpn_endpoint.private_ip}" }
output "module_dependency_id" { value = "${null_resource.module_dependency.id}" }
