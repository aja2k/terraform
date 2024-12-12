# Import SSH Key
#import {
#  to = ncloud_login_key.loginkey
#  id = "test-key2"
#}
# 로그인 키 생성
resource "ncloud_login_key" "key" {
  key_name = local.key_name
}
# kubeconfig 데이터 소스
data "ncloud_nks_kube_config" "kube_config" {
  for_each = var.clusters
  
  cluster_uuid = ncloud_nks_cluster.clusters[each.key].uuid
}

# Export SSH Key
resource "local_sensitive_file" "ssh_key" {
  filename          = "./${var.env}-key.pem"
  content          = ncloud_login_key.key.private_key
  file_permission  = "0600"
}

# ACG (Access Control Group) 생성
resource "ncloud_access_control_group" "acg" {
  name = local.acg_name
  vpc_no = ncloud_vpc.vpc.id
}

# ACG 규칙 생성
resource "ncloud_access_control_group_rule" "acg_rules" {
  access_control_group_no = ncloud_access_control_group.acg.id  # ACG 연결

  # 인바운드 규칙 - k8s 필수 포트
  dynamic "inbound" {
    for_each = local.k8s_ports                  # k8s 포트 목록 순회
    content {
      protocol    = "TCP"                       # TCP 프로토콜
      ip_block    = "0.0.0.0/0"                # 모든 IP 허용
      port_range  = inbound.value                # 포트 범위
      description = "K8s ${inbound.key} port"  # 규칙 설명
    }
  }

  # 아웃바운드 규칙 - TCP
  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "All outbound TCP traffic"
  }

  # 아웃바운드 규칙 - UDP
  outbound {
    protocol    = "UDP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "All outbound UDP traffic"
  }
}
#ACG 적용 (NKS 클러스터 노드에 적용)
resource "null_resource" "apply_acg" {
  provisioner "local-exec" {
    working_dir = "${path.module}/shell"
    command     = "./apply_acg.sh"
  }

  depends_on = [
    ncloud_nks_cluster.clusters,
    local_file.cluster_info,
    local_file.node_info,
    ncloud_access_control_group_rule.acg_rules
  ]
}

# ArgoCD 로그인을 위한 별도 리소스
resource "null_resource" "argocd_login" {
  provisioner "local-exec" {
    command = <<-EOT
      if ! argocd account get-user-info &>/dev/null; then
        echo "Logging into ArgoCD..."
        argocd login argocd.milkt.co.kr --username admin --password '52(,c%fATWi!p,K' --insecure || {
          echo "ArgoCD 로그인 실패"
          exit 1
        }
      else
        echo "Already logged into ArgoCD"
      fi
    EOT
  }
  depends_on = [
    ncloud_nks_cluster.clusters
  ]
}