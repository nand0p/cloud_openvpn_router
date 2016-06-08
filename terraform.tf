variable "access_key" {}
variable "secret_key" {}
variable "trusted_ip" {}
variable "stack_name" {}
variable "region" { default = "us-east-1" }  
variable "openvpn_port" { default = 443 }
variable "image_id" { default = "ami-f5f41398" }
variable "instance_type" { default = "t2.small" }

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_key_pair" "openvpn" {
  key_name = "${var.stack_name}" 
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_vpc" "openvpn" {
    cidr_block = "10.10.10.0/24"
    tags { Name = "${var.stack_name}" }
}

resource "aws_subnet" "openvpn" {
    vpc_id = "${aws_vpc.openvpn.id}"
    cidr_block = "10.10.10.0/24"
    tags { Name = "${var.stack_name}" }
}

resource "aws_internet_gateway" "openvpn" {
    vpc_id = "${aws_vpc.openvpn.id}"
    tags { Name = "${var.stack_name}" }
}

resource "aws_route_table" "openvpn" {
    vpc_id = "${aws_vpc.openvpn.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.openvpn.id}"
    }
    tags { Name = "${var.stack_name}" }
}

resource "aws_main_route_table_association" "openvpn" {
    vpc_id = "${aws_vpc.openvpn.id}"
    route_table_id = "${aws_route_table.openvpn.id}"
}

resource "aws_route_table_association" "openvpn" {
    subnet_id = "${aws_subnet.openvpn.id}"
    route_table_id = "${aws_route_table.openvpn.id}"
}

resource "aws_security_group" "openvpn" {
    name = "${var.stack_name}"
    description = "${var.stack_name}"
    vpc_id = "${aws_vpc.openvpn.id}"
    ingress {
        from_port = "${var.openvpn_port}"
        to_port = "${var.openvpn_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "${var.trusted_ip}/32" ]
    } 
    tags { Name = "${var.stack_name}" }
}

resource "aws_elb" "openvpn" {
    name = "${var.stack_name}"
    subnets = [ "${aws_subnet.openvpn.id}" ]
    security_groups = [ "${aws_security_group.openvpn.id}" ]
    listener {
      instance_port = "${var.openvpn_port}"
      instance_protocol = "tcp"
      lb_port = "${var.openvpn_port}"
      lb_protocol = "tcp"
    }
    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      target = "TCP:${var.openvpn_port}"
      interval = 10
    }
    tags { Name = "${var.stack_name}" }
}

resource "aws_autoscaling_group" "openvpn" {
    name = "${var.stack_name}"
    vpc_zone_identifier = [ "${aws_subnet.openvpn.id}" ]
    load_balancers = [ "${aws_elb.openvpn.name}" ]
    max_size = 1
    min_size = 1
    health_check_grace_period = 300
    health_check_type = "ELB"
    force_delete = true
    launch_configuration = "${aws_launch_configuration.openvpn.name}"
    tag {
      key = "Name"
      value = "${var.stack_name}"
      propagate_at_launch = true
    }
}

resource "aws_launch_configuration" "openvpn" {
    name = "${var.stack_name}"
    image_id = "${var.image_id}"
    instance_type = "${var.instance_type}"
    security_groups = [ "${aws_security_group.openvpn.id}" ]
    associate_public_ip_address = "true"
    key_name = "${aws_key_pair.openvpn.key_name}"
    user_data = "#cloud-config\npackages:\n- openvpn\n"
}        
