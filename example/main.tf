module "ad" {
  source     = "../"
  cidr_block = "10.1.0.0/16"

  # ^^ not required unless this will clash with your existing
  peer_with    = aws_vpc.vpc.*.id
  peer_count   = 2
  subnets      = aws_subnet.subnet.*.id
  subnet_count = 2

  Domain = {
    address     = "myapp.com"
    directoryOU = "OU=myapp,DC=myapp,DC=com"
  }
}

locals {
  # annoying work around for Terraform's inability to calculate counts reliably
  vpc_count    = 2
  subnet_count = 2
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "win" {
  instance_type = "t2.nano"
  ami           = data.aws_ami.win.id

  iam_instance_profile = module.ad.ad_writer_instance_profile_name
  subnet_id            = element(aws_subnet.subnet.*.id, count.index)

  vpc_security_group_ids = [
    element(aws_security_group.sg.*.id, count.index),
  ]

  count = local.subnet_count
}

data "aws_ami" "win" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "Windows_Server-2012-R2_RTM-English-64Bit-Base-*",
    ]
  }

  owners = [
    "amazon",
  ]
}

output "outputs" {
  value = {
    ad_password = module.ad.AdminPassword
    ubuntu      = aws_instance.ubuntu.*.public_dns
    windows     = aws_instance.win.*.public_dns
  }
}

resource "aws_ssm_association" "win" {
  name        = module.ad.ad_aws_ssm_document_name
  instance_id = element(aws_instance.win.*.id, count.index)
  count       = local.subnet_count
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.${count.index}.0/24"
  count                = local.vpc_count
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet" {
  vpc_id                  = element(aws_vpc.vpc.*.id, count.index)
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = cidrsubnet(element(aws_vpc.vpc.*.cidr_block, count.index), 4, 1)
  map_public_ip_on_launch = true
  count                   = local.vpc_count
}

resource "aws_security_group" "sg" {
  vpc_id = element(aws_vpc.vpc.*.id, count.index)

  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  count = local.vpc_count
}

resource "aws_internet_gateway" "igw" {
  vpc_id = element(aws_vpc.vpc.*.id, count.index)
  count  = local.vpc_count
}

resource "aws_route_table" "rt" {
  vpc_id = element(aws_vpc.vpc.*.id, count.index)

  count = local.vpc_count
}

resource "aws_route_table_association" "association" {
  route_table_id = element(aws_route_table.rt.*.id, count.index)
  subnet_id      = element(aws_subnet.subnet.*.id, count.index)
  count          = local.subnet_count
}

resource "aws_instance" "ubuntu" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id
  subnet_id     = element(aws_subnet.subnet.*.id, count.index)
  key_name      = "cns"

  vpc_security_group_ids = [
    element(aws_security_group.sg.*.id, count.index),
  ]

  count = local.subnet_count

  user_data = <<EOF
#!/bin/bash
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install sssd realmd krb5-user samba-common expect adcli sssd-tools  packagekit
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl reload sshd
systemctl start sssd.service
echo "%Domain\\ Admins@myapp.com ALL=(ALL:ALL) ALL" >>  /etc/sudoers
expect -c "spawn realm join -U admin@MYAPP.COM MYAPP.COM; expect \"*?assword for admin@MYAPP.COM:*\"; send -- \"${module.ad.AdminPassword}\r\" ; expect eof"
reboot
EOF
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-**",
    ]
  }

  filter {
    name = "root-device-type"

    values = [
      "ebs",
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm",
    ]
  }

  owners = [
    "099720109477",
  ]
}
