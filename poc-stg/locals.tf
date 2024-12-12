locals {
  vpc_name = "${var.env}-vpc"
  key_name = "${var.env}-key"
  acg_name = "${var.env}-acg"

  clusters = {
    for k, v in var.clusters : k => {
      name_prefix = "poc-${v.environment}-${v.name}"
      resource_names = {
        cluster = "poc-${v.environment}-${v.name}-k8s-${split("-", k)[1]}"
        nodepool = "poc-${v.environment}-${v.name}-np-${split("-", k)[1]}"
      }
    }
  }

  subnet_mappings = {
    for k, v in var.clusters : k => {
      lb_pub = "${split("-", k)[0]}-lb-pub-${split("-", k)[1]}"
      lb_pri = "${split("-", k)[0]}-lb-pri-${split("-", k)[1]}"
      np_pri = "${split("-", k)[0]}-np-pri-${split("-", k)[1]}"
    }
  }

  # 쿠버네티스 필수 포트 정의
  k8s_ports = {
    ssh         = "22"
    http        = "80"
    https       = "443"
    k8s_api     = "6443"
    http_alt    = "8080"
    custom_port = "18080"
    kubelet     = "10250"
    nodeport    = "30000-32768"
    etcd        = "2379-2380"
    cilium_health  = "4240"
    metrics        = "4443"
    overlay        = "8472"
    ingress_health = "10254"
  }

}