# pylint: disable=missing-docstring, line-too-long, protected-access
import unittest
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """

provider "aws" {
  region = "eu-west-2"
  skip_credentials_validation = true
  skip_get_ec2_platforms = true
}

module "ad" {
  source = "./mymodule"

  providers = {
    aws = "aws"
  }
  cidr_block = "10.1.0.0/16"

  # ^^ not required unless this will clash with your existing
  peer_with    = "${aws_vpc.vpc.*.id}"
  peer_count   = 2
  subnets      = "${aws_subnet.subnet.*.id}"
  subnet_count = 2
}
data "aws_availability_zones" "available" {}

locals {
  vpc_count    = 2
  subnet_count = 2
}

resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.${count.index}.0/24"
  count                = "${local.vpc_count}"
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet" {
  vpc_id                  = "${element(aws_vpc.vpc.*.id, count.index)}"
  availability_zone       = "eu-west-2a"
  cidr_block              = "${cidrsubnet(element(aws_vpc.vpc.*.cidr_block, count.index), 4, 1)}"
  map_public_ip_on_launch = true
  count                   = "${local.vpc_count}"
}

resource "aws_route_table" "rt" {
  vpc_id = "${element(aws_vpc.vpc.*.id, count.index)}"

  count = "${local.vpc_count}"
}

resource "aws_route_table_association" "association" {
  route_table_id = "${element(aws_route_table.rt.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  count          = "${local.subnet_count}"
}

        """
        self.runner = Runner(self.snippet)
        self.result = self.runner.result
        self.lists = [self.result['resource_changes'][i]['address'] for i in range(len(self.result['resource_changes']))]

    def test_aws_directory_service_directory_name(self):
        self.assertEqual("example.com", self.runner.get_value("module.ad.aws_directory_service_directory.ad", "name"))

    def test_aws_iam_instance_profile(self):
        self.assertIn("module.ad.aws_iam_instance_profile.adwriter", self.lists)

    def test_aws_iam_role_adwriter(self):
        self.assertIn("module.ad.aws_iam_role.adwriter", self.lists)

    def test_aws_iam_role_policy_policy_allow_all_ssm(self):
        self.assertIn("module.ad.aws_iam_role_policy.policy_allow_all_ssm", self.lists)

    def test_aws_route_peer(self):
        self.assertIn("module.ad.aws_route.peer[0]", self.lists)
        self.assertIn("module.ad.aws_route.peer[1]", self.lists)

    def test_aws_route_peers_route_table(self):
        self.assertIn("module.ad.aws_route.peers_route_table[0]", self.lists)
        self.assertIn("module.ad.aws_route.peers_route_table[1]", self.lists)

    def test_aws_route_table_route_table(self):
        self.assertIn("module.ad.aws_route_table.route_table", self.lists)

    def test_aws_route_table_association_association_2(self):
        self.assertIn("module.ad.aws_route_table_association.association[0]", self.lists)
        self.assertIn("module.ad.aws_route_table_association.association[1]", self.lists)

    def test_aws_ssm_document_ssm_doc(self):
        self.assertIn("module.ad.aws_ssm_document.ssm_doc", self.lists)

    def test_aws_subnet_subnets(self):
        self.assertIn("module.ad.aws_subnet.subnets[0]", self.lists)
        self.assertIn("module.ad.aws_subnet.subnets[1]", self.lists)

    def test_aws_vpc_vpc(self):
        self.assertIn("module.ad.aws_vpc.vpc", self.lists)

    def test_aws_vpc_dhcp_options_dns_resolver(self):
        self.assertIn("module.ad.aws_vpc_dhcp_options.dns_resolver", self.lists)

    def test_aws_vpc_dhcp_options_association_peer_dns_resolver(self):
        self.assertIn("module.ad.aws_vpc_dhcp_options_association.peer_dns_resolver[0]", self.lists)
        self.assertIn("module.ad.aws_vpc_dhcp_options_association.peer_dns_resolver[1]", self.lists)

    def test_aws_vpc_peering_connection_peering(self):
        self.assertIn("module.ad.aws_vpc_peering_connection.peering[0]", self.lists)
        self.assertIn("module.ad.aws_vpc_peering_connection.peering[1]", self.lists)

    def test_data_aws_route_table_peer_route_tables(self):
        self.assertIn("module.ad.data.aws_route_table.peer_route_tables[0]", self.lists)
        self.assertIn("module.ad.data.aws_route_table.peer_route_tables[1]", self.lists)

    def test_data_aws_vpc_peers(self):
        self.assertIn("module.ad.data.aws_vpc.peers[0]", self.lists)
        self.assertIn("module.ad.data.aws_vpc.peers[1]", self.lists)

    def test_random_string_AdminPassword(self):
        self.assertIn("module.ad.random_string.AdminPassword", self.lists)

    def test_random_string_ssm_doc_name(self):
        self.assertIn("module.ad.random_string.ssm_doc_name", self.lists)


if __name__ == '__main__':
    unittest.main()
