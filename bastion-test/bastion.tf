# ===== TASK 1: SSH 키 생성 =====
# ncloud_login_key 리소스를 사용하여 SSH 키 페어 생성
# terraform apply 후 자동으로 .pem 파일이 생성됨
# chmod 600 test-key-bst.pem 명령어로 권한 설정 필요
resource "ncloud_login_key" "loginkey" {
  key_name = "test-key-bst"  # 생성할 키 이름 지정
}

# ===== TASK 2: VPC 네트워크 구성 =====
# VPC(Virtual Private Cloud) 생성
# CIDR 블록으로 10.10.0.0/16 사용 (65,536개 IP 주소 사용 가능)
resource "ncloud_vpc" "test3" {
  ipv4_cidr_block = "10.10.0.0/16"
}

# 퍼블릭 서브넷 생성 
# cidrsubnet() 함수로 서브넷 자동 계산 (10.10.1.0/24)
resource "ncloud_subnet" "test3" {
  vpc_no         = ncloud_vpc.test3.vpc_no  # 상위 VPC 연결
  subnet         = cidrsubnet(ncloud_vpc.test3.ipv4_cidr_block, 8, 1)
  zone           = "KR-1"                   # 가용영역 설정
  network_acl_no = ncloud_vpc.test3.default_network_acl_no
  subnet_type    = "PUBLIC"                 # 퍼블릭 서브넷으로 설정
  usage_type     = "GEN"                    # 일반 서브넷으로 사용
}

# ===== TASK 3: 서버 이미지 및 스펙 설정 =====
# Rocky Linux 8.10 이미지 조회
data "ncloud_server_image_numbers" "kvm-image" {
  server_image_name = "rocky-8.10-base"  # Ubuntu 22.04도 선택 가능
  filter {
    name = "hypervisor_type"
    values = ["KVM"]                     # KVM 하이퍼바이저 사용
  }
}

# 서버 스펙 조회 (c2-g3: 2vCPU, 4GB RAM)
data "ncloud_server_specs" "kvm-spec" {
  filter {
    name   = "server_spec_code"
    values = ["c2-g3"]
  }
}

# ===== TASK 4: 초기화 스크립트 설정 =====
# 서버 생성 시 실행할 초기화 스크립트
resource "ncloud_init_script" "init" {
  name    = "ls-script"
  content = file("${path.module}/shell/init_script.sh")  # 외부 스크립트 파일 참조
}

# ===== TASK 5: 베스천 서버 생성 =====
# KVM 기반 베스천 서버 생성
resource "ncloud_server" "bastion_server" {
  subnet_no           = ncloud_subnet.test3.id
  name                = "tf-kvm-server"
  server_image_number = data.ncloud_server_image_numbers.kvm-image.image_number_list.0.server_image_number
  server_spec_code    = data.ncloud_server_specs.kvm-spec.server_spec_list.0.server_spec_code
  login_key_name      = ncloud_login_key.loginkey.key_name
  init_script_no      = ncloud_init_script.init.id
  #fee_system_type_code = "FXSUM"  # 월 정액제 과금 방식 - mi1-g3
}

# ===== TASK 6: 공인 IP 설정 =====
# 베스천 서버에 공인 IP 할당
resource "ncloud_public_ip" "bastion_ip" {
  server_instance_no = ncloud_server.bastion_server.instance_no
}

# ===== TASK 7: SSH 키 파일 생성 =====
# 생성된 SSH 키를 로컬 파일로 저장
# ssh -i test-key-bst.pem root@[공인IP] 로 접속
resource "local_sensitive_file" "ssh_key" {
  filename        = "./${ncloud_login_key.loginkey.key_name}.pem"
  content         = ncloud_login_key.loginkey.private_key
  file_permission = "0600"
}

# ===== TASK 8: 루트 비밀번호 관리 =====
# 서버의 루트 비밀번호 조회
data "ncloud_root_password" "default" {
  server_instance_no = ncloud_server.bastion_server.instance_no 
  private_key        = ncloud_login_key.loginkey.private_key 
}

# 루트 비밀번호를 파일로 저장
resource "local_file" "bastion_svr_root_pw" {
  filename = "${ncloud_server.bastion_server.name}-root_password.txt"
  content  = "${ncloud_server.bastion_server.name} => ${data.ncloud_root_password.default.root_password}"
}
