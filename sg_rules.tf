locals {
  # Map of Active Directory Security Group IDs by environment
  ad_security_groups = {
    notprod = "sg-ca1f75a2"
    #prod    = "sg-bda02bd5"
  }
}

# ==============================================================================
# Complete 18 Active Directory Inbound Security Group Rules (As-Is AWS State)
# ==============================================================================

# 1. UDP 138 - NetBIOS NetLOGON Service
resource "aws_vpc_security_group_ingress_rule" "ad_udp_138" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "NetBIOS NetLOGON Service (${each.key})"
  ip_protocol       = "udp"
  from_port         = 138
  to_port           = 138
  cidr_ipv4         = "0.0.0.0/0"
}

# 2. UDP 445 - SMB over UDP
resource "aws_vpc_security_group_ingress_rule" "ad_udp_445" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "SMB over UDP (${each.key})"
  ip_protocol       = "udp"
  from_port         = 445
  to_port           = 445
  cidr_ipv4         = "0.0.0.0/0"
}

# 3. UDP 464 - Kerberos Password Change UDP
resource "aws_vpc_security_group_ingress_rule" "ad_udp_464" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "Kerberos Password Change UDP (${each.key})"
  ip_protocol       = "udp"
  from_port         = 464
  to_port           = 464
  cidr_ipv4         = "0.0.0.0/0"
}

# 4. TCP 464 - Kerberos Password Change TCP
resource "aws_vpc_security_group_ingress_rule" "ad_tcp_464" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "Kerberos Password Change TCP (${each.key})"
  ip_protocol       = "tcp"
  from_port         = 464
  to_port           = 464
  cidr_ipv4         = "0.0.0.0/0"
}

# 5. UDP 389 - LDAP UDP Discovery
resource "aws_vpc_security_group_ingress_rule" "ad_udp_389" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "LDAP UDP (${each.key})"
  ip_protocol       = "udp"
  from_port         = 389
  to_port           = 389
  cidr_ipv4         = "0.0.0.0/0"
}

# 6. UDP 53 - DNS UDP
resource "aws_vpc_security_group_ingress_rule" "ad_udp_53" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "DNS UDP (${each.key})"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "0.0.0.0/0"
}

# 7. TCP 389 - LDAP TCP
resource "aws_vpc_security_group_ingress_rule" "ad_tcp_389" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "LDAP TCP (${each.key})"
  ip_protocol       = "tcp"
  from_port         = 389
  to_port           = 389
  cidr_ipv4         = "0.0.0.0/0"
}

# 8. ICMP All - Allow All ICMP
resource "aws_vpc_security_group_ingress_rule" "ad_icmp" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "Allow all ICMP (${each.key})"
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
}

# 9. TCP 445 - SMB over TCP
resource "aws_vpc_security_group_ingress_rule" "ad_tcp_445" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "SMB over TCP (${each.key})"
  ip_protocol       = "tcp"
  from_port         = 445
  to_port           = 445
  cidr_ipv4         = "0.0.0.0/0"
}

# 10. UDP 123 - NTP Time Synchronization
resource "aws_vpc_security_group_ingress_rule" "ad_udp_123" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "NTP Time Synchronization (${each.key})"
  ip_protocol       = "udp"
  from_port         = 123
  to_port           = 123
  cidr_ipv4         = "0.0.0.0/0"
}

# 11. TCP 88 - Kerberos Auth TCP
resource "aws_vpc_security_group_ingress_rule" "ad_tcp_88" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "Kerberos Auth TCP (${each.key})"
  ip_protocol       = "tcp"
  from_port         = 88
  to_port           = 88
  cidr_ipv4         = "0.0.0.0/0"
}

# 12. TCP 3268-3269 - Global Catalog TCP
resource "aws_vpc_security_group_ingress_rule" "ad_tcp_gc" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "Global Catalog TCP (${each.key})"
  ip_protocol       = "tcp"
  from_port         = 3268
  to_port           = 3269
  cidr_ipv4         = "0.0.0.0/0"
}

# 13. TCP 1024-65535 - Dynamic RPC Ports
resource "aws_vpc_security_group_ingress_rule" "ad_tcp_rpc_dynamic" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "AD Dynamic RPC Ports (${each.key})"
  ip_protocol       = "tcp"
  from_port         = 1024
  to_port           = 65535
  cidr_ipv4         = "0.0.0.0/0"
}

# 14. Self Ingress - Internal Security Group Communication
resource "aws_vpc_security_group_ingress_rule" "ad_self_ingress" {
  for_each                     = local.ad_security_groups
  security_group_id            = each.value
  description                  = "Allow internal communication within SG (${each.key})"
  ip_protocol                  = "-1"
  referenced_security_group_id = each.value
}

# 15. TCP 135 - RPC Endpoint Mapper
resource "aws_vpc_security_group_ingress_rule" "ad_tcp_135" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "RPC Endpoint Mapper (${each.key})"
  ip_protocol       = "tcp"
  from_port         = 135
  to_port           = 135
  cidr_ipv4         = "0.0.0.0/0"
}

# 16. TCP 636 - LDAP over SSL (LDAPS)
resource "aws_vpc_security_group_ingress_rule" "ad_tcp_636" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "LDAP over SSL (${each.key})"
  ip_protocol       = "tcp"
  from_port         = 636
  to_port           = 636
  cidr_ipv4         = "0.0.0.0/0"
}

# 17. TCP 53 - DNS TCP
resource "aws_vpc_security_group_ingress_rule" "ad_tcp_53" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "DNS TCP (${each.key})"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "0.0.0.0/0"
}

# 18. UDP 88 - Kerberos Auth UDP
resource "aws_vpc_security_group_ingress_rule" "ad_udp_88" {
  for_each          = local.ad_security_groups
  security_group_id = each.value
  description       = "Kerberos Auth UDP (${each.key})"
  ip_protocol       = "udp"
  from_port         = 88
  to_port           = 88
  cidr_ipv4         = "0.0.0.0/0"
}
