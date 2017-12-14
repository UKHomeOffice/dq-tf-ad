# Active Directory Terraform Module

Provides an Active Directory in a dedicated VPC that you can then peer with and consume.

## Features

  - [x] Automatically comes up in all the availability zones in your given region
  - [x] Requires bare minimum ceremony of configuration to use
  - [x] Provides an *Ad Writer* IAM Role which can be assigned to your AD manager instances
  - [x] Sets up DHCP options on supplied VPCs
  - [x] Encrypt the AD password with KMS

## Usage
```hcl
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
  Domain = {
    address = "mydomain.com"
    directoryOU = "OU=mydomain,DC=mydomain,DC=com"
  }
}

resource "aws_instance" "ad_writer" {
#...
  iam_instance_profile = "${module.ad.ad_writer_instance_profile_name}"
#...
}

resource "aws_ssm_association" "win" {
  name        = "${module.ad.ad_aws_ssm_document_name}"
  instance_id = "${aws_instance.ad_writer.id}"
}

```
[Or a more complete example](example/main.tf)


## Joining instances
New windows instances can be simply assigned the `iam_instance_profile` and it'll 'just work'.

For existing or linux you should login to an *AD Writer* instance and make a user with delegated permissions to.

For implementation see the [ec2 instances](https://github.com/UKHomeOffice/dq-tf-ad-demo/blob/master/ec2_instances.tf) in the [explorative demo](https://github.com/UKHomeOffice/dq-tf-ad-demo) that preceeded this module where I hacked some instances to auto join by provisioning them with some user_data. Be warned though, adding even a restriced AD account password here is a **really bad idea**.

## Keeping the AD Admin password in KMS
```bash
echo -n 'Sup3rS3cret' > plaintext-password
aws kms encrypt \
 --key-id YOUR_KEY_ID \
 --plaintext fileb://plaintext-password \
 --encryption-context terraform=active_directory \
 --output text --query CiphertextBlob
AQECA......P8dPp28OoAQ==
```
```hcl
data "aws_kms_secret" "ad_admin_password" {
  secret {
    name    = "pass"
    payload = "AQECA......P8dPp28OoAQ=="

    context {
      terraform = "active_directory"
    }
  }
}

module "ad" {
  AdminPassword = "${data.aws_kms_secret.ad_admin_password.pass}"
}
```
## Related reading
This module is based off the explorative work done in the [dq-tf-ad-demo](https://github.com/UKHomeOffice/dq-tf-ad-demo) repository.

## Contributions
Pull requests welcome!