data "ncloud_nks_versions" "version" {
  hypervisor_code = "KVM"
  filter {
    name = "value"
    values = ["1.29"]
    regex = true
  }
}
# NKS 클러스터 생성
resource "ncloud_nks_cluster" "clusters" {
  for_each = var.clusters

  name = local.clusters[each.key].resource_names.cluster
  hypervisor_code = "KVM"
  #cluster_type =  SVR.VNKS.STAND.C002.M008.G003, SVR.VNKS.STAND.C004.M016.G003
  cluster_type = "SVR.VNKS.STAND.C002.M008.G003"
  k8s_version = data.ncloud_nks_versions.version.versions.0.value
  login_key_name = local.key_name
  vpc_no = ncloud_vpc.vpc.id
  kube_network_plugin = "cilium"
  subnet_no_list = [ncloud_subnet.subnets[local.subnet_mappings[each.key].np_pri].id]
  zone = each.value.zone
  lb_private_subnet_no = ncloud_subnet.subnets[local.subnet_mappings[each.key].lb_pri].id
  lb_public_subnet_no = ncloud_subnet.subnets[local.subnet_mappings[each.key].lb_pub].id

}
