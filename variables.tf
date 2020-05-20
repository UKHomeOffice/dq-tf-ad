variable "cidr_block" {
  description = "CIDR block for the AD subnet to use"
  default     = "10.1.0.0/16"
  type        = string
}

variable "peer_with" {
  description = "List of VPC IDs you'd like to peer the AD with"
  type        = list(string)
  default     = []
}

variable "peer_count" {
  description = "Count of how many things are in `peer_with`"
  type        = string
  default     = 0
}

variable "subnet_count" {
  description = "Count of how many things are in `subnets`"
  type        = string
  default     = 0
}

variable "subnets" {
  description = "List of subnet IDs you'd like rules made for"
  type        = list(string)
}

variable "AdminPassword" {
  description = "The AD admin password to use, if you don't specify one a random one will be generated"
  default     = false
}

variable "Domain" {
  description = "Domain to create in AD"
  type        = map(string)

  default = {
    address     = "example.com"
    directoryOU = "OU=example,DC=example,DC=com"
  }
}

variable "allow_remote_vpc_dns_resolution" {
  description = "allow_remote_vpc_dns_resolution on peers"
  default     = true
}

variable "public_dns_servers" {
  description = "Map of Public DNS servers."
  type        = list(string)

  default = [
    "8.8.8.8",
    "8.8.4.4",
  ]
}

