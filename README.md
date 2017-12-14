# Active Directory Terraform Module

Provides an Active Directory in a dedicated VPC that you can then peer with and consume.

## Features

  - [x] Automatically comes up in all the availability zones in your given region
  - [x] Only needs a VPC CIDR Block given to it
  - [x] Provides an *Ad Writer* IAM Role which can be assigned to your AD manager instances
  - [x] Provides a DHCP options that you can add to your VPC so that all DNS is routed to the AD
  - [ ] Encrypt the AD password with KMS

## Usage
```hcl
resource "aws_ssm_association" "win" {
  name        = "${module.ad.ad_aws_ssm_document_name}"
  instance_id = "${element(aws_instance.win.*.id, count.index)}"
}

module "ad" {
  source = "github.com/ukhomeoffice/dq-tf-ad"
  peer_with = [
    "${aws_vpc.YOURVPC1.id}",
    "${aws_vpc.YOURVPC2.id}"
  ]
  peer_count   = 2
  subnets      = [
  "${aws_subnet.YOUSSUBNET1.id}",
  "${aws_subnet.YOUSSUBNET2.id}",
  ]
  subnet_count = 2
  default = {
    address = "mydomain.com"
    directoryOU = "OU=mydomain,DC=mydomain,DC=com"
  }
}

resource "aws_instance" "ad_writer" {
#...
  iam_instance_profile = "${module.ad.ad_writer_instance_profile_name}"
#...
}

```
[Or a more complete example](example/main.tf)


## Joining instances
New windows instances can be simply assigned the `iam_instance_profile` and it'll 'just work'.

For existing or linux you should login to an *AD Writer* instance and make a user with delegated permissions to.

For implementation see the [ec2 instances](https://github.com/UKHomeOffice/dq-tf-ad-demo/blob/master/ec2_instances.tf) in the [explorative demo](https://github.com/UKHomeOffice/dq-tf-ad-demo) that preceeded this module where I hacked some instances to auto join by provisioning them with some user_data. Be warned though, adding even a restriced AD account password here is a **really bad idea**.

## Related reading
This module is based off the explorative work done in the [dq-tf-ad-demo](https://github.com/UKHomeOffice/dq-tf-ad-demo) repository.

## Contributions
Pull requests welcome!