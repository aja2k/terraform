## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ncloud"></a> [ncloud](#requirement\_ncloud) | 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |
| <a name="provider_ncloud"></a> [ncloud](#provider\_ncloud) | 3.2.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.cluster_info](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.node_info](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_sensitive_file.ssh_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [ncloud_access_control_group.acg](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/access_control_group) | resource |
| [ncloud_access_control_group_rule.acg_rules](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/access_control_group_rule) | resource |
| [ncloud_login_key.key](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/login_key) | resource |
| [ncloud_nks_cluster.clusters](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/nks_cluster) | resource |
| [ncloud_nks_node_pool.node_pool](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/nks_node_pool) | resource |
| [ncloud_route_table.private](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/route_table) | resource |
| [ncloud_route_table.public](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/route_table) | resource |
| [ncloud_route_table_association.subnet_associations](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/route_table_association) | resource |
| [ncloud_subnet.subnets](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/subnet) | resource |
| [ncloud_vpc.vpc](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/resources/vpc) | resource |
| [null_resource.apply_acg](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.apply_init_script1](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.argocd_login](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [ncloud_nks_kube_config.kube_config](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/data-sources/nks_kube_config) | data source |
| [ncloud_nks_server_images.image](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/data-sources/nks_server_images) | data source |
| [ncloud_nks_server_products.product](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/data-sources/nks_server_products) | data source |
| [ncloud_nks_versions.version](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/3.2.1/docs/data-sources/nks_versions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Naver Cloud Platform access key | `string` | n/a | yes |
| <a name="input_clusters"></a> [clusters](#input\_clusters) | cluster configuration | <pre>map(object({<br/>    name        = string<br/>    environment = string<br/>    zone        = string<br/>    nodepool = object({<br/>      node_count = number<br/>      storage_size = number<br/>      autoscale = object({<br/>        min = number<br/>        max = number<br/>      })<br/>      labels = map(string)<br/>    })<br/>  }))</pre> | <pre>{<br/>  "bof-1": {<br/>    "environment": "prd",<br/>    "name": "bof",<br/>    "nodepool": {<br/>      "autoscale": {<br/>        "max": 8,<br/>        "min": 4<br/>      },<br/>      "labels": {<br/>        "environment": "prd-bof-1",<br/>        "role": "worker"<br/>      },<br/>      "node_count": 4,<br/>      "storage_size": 600<br/>    },<br/>    "zone": "KR-1"<br/>  },<br/>  "bof-2": {<br/>    "environment": "prd",<br/>    "name": "bof",<br/>    "nodepool": {<br/>      "autoscale": {<br/>        "max": 1,<br/>        "min": 1<br/>      },<br/>      "labels": {<br/>        "environment": "prd-bof-2",<br/>        "role": "worker"<br/>      },<br/>      "node_count": 1,<br/>      "storage_size": 600<br/>    },<br/>    "zone": "KR-2"<br/>  },<br/>  "cmn-1": {<br/>    "environment": "prd",<br/>    "name": "cmn",<br/>    "nodepool": {<br/>      "autoscale": {<br/>        "max": 8,<br/>        "min": 4<br/>      },<br/>      "labels": {<br/>        "environment": "prd-cmn-1",<br/>        "role": "worker"<br/>      },<br/>      "node_count": 4,<br/>      "storage_size": 600<br/>    },<br/>    "zone": "KR-1"<br/>  },<br/>  "cmn-2": {<br/>    "environment": "prd",<br/>    "name": "cmn",<br/>    "nodepool": {<br/>      "autoscale": {<br/>        "max": 1,<br/>        "min": 1<br/>      },<br/>      "labels": {<br/>        "environment": "prd-cmn-2",<br/>        "role": "worker"<br/>      },<br/>      "node_count": 1,<br/>      "storage_size": 600<br/>    },<br/>    "zone": "KR-2"<br/>  }<br/>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | environment | `string` | `"poc-prd"` | no |
| <a name="input_network"></a> [network](#input\_network) | 네트워크 설정 | <pre>object({<br/>    vpc_cidr = string<br/>    subnets = map(object({<br/>      name = string<br/>      cidr = string<br/>      type = string<br/>      usage = string<br/>    }))<br/>  })</pre> | <pre>{<br/>  "subnets": {<br/>    "bof-lb-pri-1": {<br/>      "cidr": "10.101.3.0/24",<br/>      "name": "bof-lb-pri-sbn-1",<br/>      "type": "PRIVATE",<br/>      "usage": "LOADB"<br/>    },<br/>    "bof-lb-pri-2": {<br/>      "cidr": "10.101.103.0/24",<br/>      "name": "bof-lb-pri-sbn-2",<br/>      "type": "PRIVATE",<br/>      "usage": "LOADB"<br/>    },<br/>    "bof-lb-pub-1": {<br/>      "cidr": "10.101.1.0/24",<br/>      "name": "bof-lb-pub-sbn-1",<br/>      "type": "PUBLIC",<br/>      "usage": "LOADB"<br/>    },<br/>    "bof-lb-pub-2": {<br/>      "cidr": "10.101.101.0/24",<br/>      "name": "bof-lb-pub-sbn-2",<br/>      "type": "PUBLIC",<br/>      "usage": "LOADB"<br/>    },<br/>    "bof-np-pri-1": {<br/>      "cidr": "10.101.5.0/24",<br/>      "name": "bof-np-pri-sbn-1",<br/>      "type": "PRIVATE",<br/>      "usage": "GEN"<br/>    },<br/>    "bof-np-pri-2": {<br/>      "cidr": "10.101.105.0/24",<br/>      "name": "bof-np-pri-sbn-2",<br/>      "type": "PRIVATE",<br/>      "usage": "GEN"<br/>    },<br/>    "bof-vm-pri-1": {<br/>      "cidr": "10.101.4.0/24",<br/>      "name": "bof-vm-pri-sbn-1",<br/>      "type": "PRIVATE",<br/>      "usage": "GEN"<br/>    },<br/>    "bof-vm-pri-2": {<br/>      "cidr": "10.101.104.0/24",<br/>      "name": "bof-vm-pri-sbn-2",<br/>      "type": "PRIVATE",<br/>      "usage": "GEN"<br/>    },<br/>    "bof-vm-pub-1": {<br/>      "cidr": "10.101.2.0/24",<br/>      "name": "bof-vm-pub-sbn-1",<br/>      "type": "PUBLIC",<br/>      "usage": "GEN"<br/>    },<br/>    "bof-vm-pub-2": {<br/>      "cidr": "10.101.102.0/24",<br/>      "name": "bof-vm-pub-sbn-2",<br/>      "type": "PUBLIC",<br/>      "usage": "GEN"<br/>    },<br/>    "cmn-lb-pri-1": {<br/>      "cidr": "10.101.8.0/24",<br/>      "name": "cmn-lb-pri-sbn-1",<br/>      "type": "PRIVATE",<br/>      "usage": "LOADB"<br/>    },<br/>    "cmn-lb-pri-2": {<br/>      "cidr": "10.101.108.0/24",<br/>      "name": "cmn-lb-pri-sbn-2",<br/>      "type": "PRIVATE",<br/>      "usage": "LOADB"<br/>    },<br/>    "cmn-lb-pub-1": {<br/>      "cidr": "10.101.6.0/24",<br/>      "name": "cmn-lb-pub-sbn-1",<br/>      "type": "PUBLIC",<br/>      "usage": "LOADB"<br/>    },<br/>    "cmn-lb-pub-2": {<br/>      "cidr": "10.101.106.0/24",<br/>      "name": "cmn-lb-pub-sbn-2",<br/>      "type": "PUBLIC",<br/>      "usage": "LOADB"<br/>    },<br/>    "cmn-np-pri-1": {<br/>      "cidr": "10.101.10.0/24",<br/>      "name": "cmn-np-pri-sbn-1",<br/>      "type": "PRIVATE",<br/>      "usage": "GEN"<br/>    },<br/>    "cmn-np-pri-2": {<br/>      "cidr": "10.101.110.0/24",<br/>      "name": "cmn-np-pri-sbn-2",<br/>      "type": "PRIVATE",<br/>      "usage": "GEN"<br/>    },<br/>    "cmn-vm-pri-1": {<br/>      "cidr": "10.101.9.0/24",<br/>      "name": "cmn-vm-pri-sbn-1",<br/>      "type": "PRIVATE",<br/>      "usage": "GEN"<br/>    },<br/>    "cmn-vm-pri-2": {<br/>      "cidr": "10.101.109.0/24",<br/>      "name": "cmn-vm-pri-sbn-2",<br/>      "type": "PRIVATE",<br/>      "usage": "GEN"<br/>    },<br/>    "cmn-vm-pub-1": {<br/>      "cidr": "10.101.7.0/24",<br/>      "name": "cmn-vm-pub-sbn-1",<br/>      "type": "PUBLIC",<br/>      "usage": "GEN"<br/>    },<br/>    "cmn-vm-pub-2": {<br/>      "cidr": "10.101.107.0/24",<br/>      "name": "cmn-vm-pub-sbn-2",<br/>      "type": "PUBLIC",<br/>      "usage": "GEN"<br/>    }<br/>  },<br/>  "vpc_cidr": "10.101.0.0/16"<br/>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | 네이버 클라우드 리전 | `string` | `"KR"` | no |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | Naver Cloud Platform secret key | `string` | n/a | yes |

## Outputs

No outputs.
