data "ncloud_server_image_numbers" "kvm-image" {
  server_image_name = "ubuntu-22.04-base"
  filter {
    name = "hypervisor_type"
    values = ["KVM"]
  }
}

data "ncloud_server_specs" "kvm-spec" {
  filter {
    name   = "server_spec_code"
    values = ["mi1-g3"]
  }
}

resource "ncloud_server" "bastion_server" {
  subnet_no                 = ncloud_subnet.subnets["cmn-vm-pub-1"].id
  name                      = "poc-stg-cmn-bst-1"
  server_image_number       = data.ncloud_server_image_numbers.kvm-image.image_number_list.0.server_image_number
  server_spec_code          = data.ncloud_server_specs.kvm-spec.server_spec_list.0.server_spec_code
  login_key_name        = local.key_name
  fee_system_type_code      = "FXSUM"
}

# 공인 IP 할당
resource "ncloud_public_ip" "bastion_ip" {
  server_instance_no = ncloud_server.bastion_server.instance_no
}

### Export Root Password ###
data "ncloud_root_password" "bastion" {
  server_instance_no = ncloud_server.bastion_server.instance_no 
  private_key = ncloud_login_key.key.private_key
}

resource "local_file" "bastion_svr_root_pw" {
  filename = "${ncloud_server.bastion_server.name}-root_password.txt"
  content = "${ncloud_server.bastion_server.name} => ${data.ncloud_root_password.bastion.root_password}"
}
