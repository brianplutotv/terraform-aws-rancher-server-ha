# Terraform AWS - Rancher 2 HA Module

This the second in a series of repositories for using Terraform to create and manage environments within AWS.

#### Series

1. [Terraform AWS - Network](https://github.com/nuarch/terraform-aws-network)
2. [Terraform AWS - Rancher 2 HA Module](https://github.com/nuarch/terraform-aws-rancher-server-ha)

## Overview

Rancher2 is a Kubernetes cluster management platform that allows DevOps teams to centrally manage K8s clusters deployed anywhere and deliver Kubernetes-as-a-Service.  This module allows you to deploy Rancher deploy to either the secure network or simple network create in Part 1.

> Currently, this module only allows deployment of Rancher 2 to the simple network architecture.  Secure network deployment is in the works.

### Features


### Credits

This module builds off of the great work by Taylor Price (of Rancher) and Jeff Bachtel [Terraform Rancher Server on GitHub](https://github.com/rancher/terraform-rancher-server).

#### Changes

* 3 Node deployment with each node configured with all K8s roles (controlplane, ectd, worker) as [recommended](https://rancher.com/docs/rancher/v2.x/en/overview/architecture-recommendations/) by Rancher
* Altered to work with [Terraform AWS - Network](https://bitbucket.org/nuarch/terraform-aws-network) module
* Auto-scaling groups and instance templates removed
* Network creation removed
* GitHub authentication removed
* Pre-commit removed

## Prerequisites

- [Prerequisites from Part 1](https://bitbucket.org/nuarch/terraform-aws-network)
- [RKE Provider v1.0.0-rc4](https://github.com/yamamoto-febc/terraform-provider-rke#installation) (Need to manually install)

## Terraform Module

```hcl
module "rancher_ha-deployment" {
  aws_profile                = "default"
  aws_region                 = "us-east-2"
  app_vpc_tags = {
    "Name" : "DEV"
  }
  custom_tags = {
    "Purpose" : "Operations"
    "Project" : "Rancher"
    "Environment" : "DEV"
    "Owner" : "DevOps"
  }

  domain           = "my.space"
  instance_type    = "t3.large"
  name             = "rancher"  
  rancher_password = "admin"
  instance_amis    = var.instance_amis

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_profile |  | string | `"rancher-eng"` | no |
| aws\_region |  | string | `"us-west-2"` | no |
| certmanager\_chart | Helm chart to use for cert-manager install | string | `"jetstack/cert-manager"` | no |
| certmanager\_version | Version of cert-manager to install | string | `"0.14.0"` | no |
| custom\_tags | Custom tags for Rancher resources | map | `{ "DoNotDelete": "true", "Owner": "EIO_Demo" }` | no |
| domain |  | string | `" rancher.my.space"` | no |
| environment\_tag |  | string | "DEV" | no |
| extra\_ssh\_keys | Extra ssh keys to inject into Rancher instances | list | `[]` | no |
| key_path | Where to save the id_rsa config file. Should end in a forward slash `/` . | string | `"./"` | no |
| instance\_type |  | string | `"t3.large"` | no |
| le\_email | LetsEncrypt email address to use | string | `"none@none.com"` | no |
| subnet\_ids\_nodes | List of subnet ids for Rancher nodes | list | `[]` | no |
| rancher\_chart | Helm chart to use for Rancher install | string | `"rancher-stable/rancher"` | no |
| rancher\_current\_password | Rancher admin user current password | string | `"null"` | no |
| rancher\_password | Password to set for Rancher root user | string | n/a | yes |
| rancher\_version | Version of Rancher to install | string | `"2.3.5"` | no |
| rke\_backups\_region | Region to perform backups to S3 in. Defaults to aws_region | string | `""` | no |
| rke\_backups\_s3\_endpoint | Override for S3 endpoint to use for backups | string | `""` | no |
| app\_vpc\_tags | If not provided, one will be created. | string | `"DEV"` | no |
| app\_subnet\_tags | If not provided, one will be created. | string | `"purpose_app = true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| address | ELB IP address |
| available\_availability\_zones | List of availability zones the were active during this deployment |
| etcd\_backup\_s3\_bucket\_id | S3 bucket ID for etcd backups |
| etcd\_backup\_user\_key | AWS IAM access key id for etcd backup user |
| etcd\_backup\_user\_secret | AWS IAM secret access key for etcd backup user |
| instance_ips | Address of Rancher nodes |

| rancher\_admin\_password | Password set for Rancher local admin user |
| rancher\_api\_url | FQDN of Rancher's Kubernetes API endpoint |
| rancher\_token | Admin token for Rancher cluster use |
| rancher\_url | URL at which to reach Rancher |

## Deployment Instructions

1. Checkout repository and make sure all prerequisites are installed and configured
2. Initialize the terraform providers and modules via
        terraform init
3. Optionally change module options in *main.tf*
4. Deploy via
        terraform apply

**Note:** See [Terraform AWS - Network](https://bitbucket.org/nuarch/terraform-aws-rancher-server-ha) for other terraform deployment commands.

# License

Modifications Copyright (c) 2020 nuArch LLC (https://www.nuarch.com)

Copyright (c) 2014-2019 [Rancher Labs, Inc.](http://rancher.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
