resource "aws_instance" "vpn_endpoint" {
    ami = "${var.mod_rhel_ami}"
    availability_zone = "${element(split(",", var.mod_azs), count.index)}"
    instance_type = "t2.micro"
    key_name = "${var.mod_aws_key_name}"
    vpc_security_groups_ids = [ "${aws_security_group.ovpn_access.id}" ]
    subnet_id     = "${element(split(",", var.mod_subnet_ids), count.index)}"
    count         = "1"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "${var.mod_vpc_name} vpn endpoint"
    }
    connection {
      user = "ec2-user"
      key_file = "${var.mod_aws_key_path}"
    }
    provisioner "remote-exec" {
      inline = [
      "sudo yum install git -y",
      "mkdir -p ~/cookbooks/ctt_ovpn",
      "git clone https://github.com/christianTragesser/cookbook-ctt_ovpn.git ~/cookbooks/ctt_ovpn",
      "cd ~/cookbooks/ctt_ovpn && berks install",
      "cd ~/cookbooks/ctt_ovpn && berks vendor ~/cookbooks",
      "sudo chef-client -z -o ctt_ovpn::default"
      ]
    }
}
/* VPN Security Group */
resource "aws_security_group" "ovpn_access" {
  name = "ovpn_access"
  description = "SSL VPN and SSH access"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${var.mod_vpc_id}"
  tags {
    Name = "SSL VPN access"
  }
}
/* null_resource exists to provide dependency hook for creation of systems and environments dependant on vpc creation */
resource "null_resource" "module_dependency" {
  depends_on = ["aws_instance.vpn_endpoint"]
}

