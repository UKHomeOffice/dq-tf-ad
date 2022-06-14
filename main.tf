provider "aws" {
}

resource "random_string" "AdminPassword" {
  length  = 16
  special = false
}

# resource "aws_ssm_parameter" "AdminPasswordd" {
#   name  = "AD_AdminPasswordd"
#   type  = "SecureString"
#   value = random_string.AdminPassword.result
# }

locals {
  AdminPassword = var.AdminPassword == false ? var.AdminPassword : random_string.AdminPassword.result
}

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_directory_service_directory" "ad" {
  name     = var.Domain["address"]
  password = local.AdminPassword
  size     = "Large"

  vpc_settings {
    vpc_id = aws_vpc.vpc.id

    subnet_ids = flatten(aws_subnet.subnets.*.id)
  }

  type = "MicrosoftAD"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      password,
    ]
  }
}

resource "aws_subnet" "subnets" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  count                   = 2
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
}

data "aws_vpc" "peers" {
  id    = var.peer_with[count.index]
  count = var.peer_count
}

resource "aws_route" "peer" {
  route_table_id            = aws_route_table.route_table.id
  vpc_peering_connection_id = element(aws_vpc_peering_connection.peering.*.id, count.index)
  destination_cidr_block    = element(data.aws_vpc.peers.*.cidr_block, count.index)

  count = var.peer_count
}

data "aws_route_table" "peer_route_tables" {
  subnet_id = var.subnets[count.index]
  count     = var.subnet_count
}

resource "aws_route" "peers_route_table" {
  route_table_id            = element(data.aws_route_table.peer_route_tables.*.id, count.index)
  vpc_peering_connection_id = element(aws_vpc_peering_connection.peering.*.id, count.index)
  destination_cidr_block    = aws_vpc.vpc.cidr_block

  count = var.subnet_count
}

resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id = aws_vpc.vpc.id
  vpc_id      = var.peer_with[count.index]
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }

  count = var.peer_count
}

resource "aws_route_table_association" "association" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = element(aws_subnet.subnets.*.id, count.index)
  count          = var.subnet_count
}

resource "aws_iam_instance_profile" "adwriter" {
  role = aws_iam_role.adwriter.name
}

resource "aws_iam_role" "adwriter" {
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

}

resource "aws_iam_role_policy" "policy_allow_all_ssm" {
  role = aws_iam_role.adwriter.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToSSM",
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:ListAssociations",
                "ssm:GetDocument",
                "ssm:ListInstanceAssociations",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation",
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply",
                "ds:CreateComputer",
                "ds:DescribeDirectories",
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = flatten([
    aws_directory_service_directory.ad.dns_ip_addresses,
    "AmazonProvidedDNS",
  ])

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      domain_name_servers,

    ]
  }
}

resource "aws_vpc_dhcp_options_association" "peer_dns_resolver" {
  vpc_id          = var.peer_with[count.index]
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
  count           = var.peer_count
}

resource "random_string" "ssm_doc_name" {
  length  = 8
  special = false
}

resource "aws_ssm_document" "ssm_doc" {
  name          = "ssm_doc_${random_string.ssm_doc_name.result}"
  document_type = "Command"

  content = <<DOC
{
        "schemaVersion": "1.2",
        "description": "Join an instance to a domain",
        "runtimeConfig": {
           "aws:domainJoin": {
               "properties": {
                  "directoryId": "${aws_directory_service_directory.ad.id}",
                  "directoryName": "${var.Domain["address"]}",
                  "directoryOU": "${var.Domain["directoryOU"]}",
                  "dnsIpAddresses": ${jsonencode(aws_directory_service_directory.ad.dns_ip_addresses)}
               }
           }
        }
}
DOC

  lifecycle {
    ignore_changes = [
      name,
      content,
    ]
  }

}
