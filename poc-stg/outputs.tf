
# 통합된 클러스터 및 노드풀 정보 파일
resource "local_file" "cluster_info" {
  filename = "${path.module}/cluster_info.txt"
  content = join("\n", flatten([
    "# Cluster Information",
    [for k, v in ncloud_nks_cluster.clusters : join("\n", [
      "Cluster: ${k}",
      "  Name: ${v.name}",
      "  K8s Version: ${v.k8s_version}",
      "  VPC No: ${v.vpc_no}",
      "  Zone: ${v.zone}",
      "  UUID: ${v.uuid}",
      "---"
    ])],
    "# Bastion Server Info",
    "Server Name: ${ncloud_server.bastion_server.name}",
    "Private IP: ${ncloud_server.bastion_server.network_interface[0].private_ip}",
    "Public IP: ${ncloud_server.bastion_server.public_ip}",
    "Server Spec: ${data.ncloud_server_specs.kvm-spec.server_spec_list.0.server_spec_code}",
    "Image: ubuntu-22.04-base",
    "Zone: ${ncloud_server.bastion_server.zone}",
    "",
    "# Cluster UUID Mapping & Kubeconfig Commands",
    [for k, v in ncloud_nks_cluster.clusters : join("\n", [
      "${v.name}:${v.uuid}",
      "Command: ncp-iam-authenticator update-kubeconfig --clusterUuid ${v.uuid} --region KR",
      "Command: kubectl config rename-context nks_kr_${v.name}_${v.uuid} ${join("", [
        substr(split("-", v.name)[1], 0, 1),  # p from prd or s from stg
        substr(split("-", v.name)[2], 0, 1),  # b from bof
        split("-", v.name)[4]                 # 1 from the last segment
      ])}"
    ])],
    "",
    "# Nodepool Details",
    [
      for k, v in ncloud_nks_node_pool.node_pool : [
        "Cluster: ${k}",
        "Nodes:",
        [for node in v.nodes : "  - ${node.name}: private_ip=${node.private_ip}, public_ip=${node.public_ip}"],
        "---"
      ]
    ],
    "",
    "# bashrc alias",
    "alias pb1='kubectl config use-context pb1'",
    "alias pb2='kubectl config use-context pb2'",
    "alias pc1='kubectl config use-context pc1'",
    "alias pc2='kubectl config use-context pc2'",
    "alias sb1='kubectl config use-context sb1'",
    "alias sb2='kubectl config use-context sb2'",
    "alias sc1='kubectl config use-context sc1'",
    "alias sc2='kubectl config use-context sc2'"
  ]))
}

# 노드 NIC 정보 파일 생성
resource "local_file" "node_info" {
  filename = "${path.module}/node_info.json"
  content = jsonencode({
    acg = {
      id = ncloud_access_control_group.acg.id
      name = ncloud_access_control_group.acg.name
    }
    nodes = {
      for k, v in ncloud_nks_node_pool.node_pool : k => {
        cluster_name = ncloud_nks_cluster.clusters[k].name
        nodes = [
          for node in v.nodes : {
            name = node.name
            private_ip = node.private_ip
            server_instance_no = node.instance_no
          }
        ]
      }
    }
  })
}