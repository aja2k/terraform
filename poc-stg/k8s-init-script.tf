# 각 클러스터의 kubeconfig 생성 및 init-script 적용
resource "null_resource" "apply_init_script" {
  for_each = var.clusters

  provisioner "local-exec" {
    command = <<-EOT
      # 경로 변수 설정
      KUBECONFIG_PATH="${path.module}/kubeconfig"
      CLUSTER_KUBECONFIG="$KUBECONFIG_PATH/${each.value.environment}-${each.key}"
      ARGOCD_KUBECONFIG="$KUBECONFIG_PATH/kubeconfig-argocd"
      
      # kubeconfig 파일 권한 설정
      chmod 600 "$CLUSTER_KUBECONFIG"
      
      # 1. kubeconfig 생성
      if [ ! -f "$CLUSTER_KUBECONFIG" ]; then
        echo "Creating kubeconfig for cluster ${each.value.environment}-${each.key}..."
        ncp-iam-authenticator create-kubeconfig \
          --clusterUuid ${ncloud_nks_cluster.clusters[each.key].uuid} \
          --region KR \
          --output "$CLUSTER_KUBECONFIG"
      fi
      
      # 2. 스크립트 해시값 계산 및 Base64 인코딩
      SCRIPT_HASH=$(sha256sum ${path.module}/shell/init_script.sh | cut -d' ' -f1)
      ENCODED_SCRIPT=$(base64 ${path.module}/shell/init_script.sh -w 0)
      
      # 3. 현재 적용된 스크립트의 해시값 확인
      CURRENT_SCRIPT=$(kubectl --kubeconfig="$CLUSTER_KUBECONFIG" get daemonset/init-script -n kube-system -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="STARTUP_SCRIPT")].value}' 2>/dev/null || echo "")
      CURRENT_HASH=$(echo "$CURRENT_SCRIPT" | base64 -d 2>/dev/null | sha256sum | cut -d' ' -f1 || echo "")
      
      # 4. 해시값이 다른 경우에만 스크립트 업데이트
      if [ "$SCRIPT_HASH" != "$CURRENT_HASH" ]; then
        echo "스크립트가 변경되어 업데이트를 진행합니다..."
        kubectl --kubeconfig="$CLUSTER_KUBECONFIG" apply -f ${path.module}/manifest/initscript-kr.yml
        kubectl --kubeconfig="$CLUSTER_KUBECONFIG" set env daemonset/init-script -n kube-system STARTUP_SCRIPT=$ENCODED_SCRIPT
      else
        echo "스크립트가 변경되지 않았습니다. 업데이트를 건너뜁니다."
      fi

      # 5. Helm 레포지토리 추가 및 업데이트
      if ! helm repo list --kubeconfig="$CLUSTER_KUBECONFIG" | grep "poc-helm"; then
        helm repo add poc-helm https://git-poc.milkt.co.kr/api/v4/projects/3/packages/helm/stable --kubeconfig="$CLUSTER_KUBECONFIG"
        helm repo update --kubeconfig="$CLUSTER_KUBECONFIG"
      fi

      # 6. ingress-nginx 설치 확인 및 설치
      if ! helm list -A --kubeconfig="$CLUSTER_KUBECONFIG" | grep "${each.value.environment}-${each.key}-ingress-nginx"; then
        helm upgrade --install ${each.value.environment}-${each.key}-ingress-nginx \
          poc-helm/stg-ingress-nginx \
          --namespace ingress-nginx \
          --create-namespace \
          --kubeconfig="$CLUSTER_KUBECONFIG"
      fi

      # 7. nfs-subdir 설치 확인 및 설치
      if ! helm list -A --kubeconfig="$CLUSTER_KUBECONFIG" | grep "${each.value.environment}-${each.key}-nfs-subdir"; then
        helm upgrade --install ${each.value.environment}-${each.key}-nfs-subdir \
          poc-helm/stg-nfs-subdir \
          --namespace nfs-subdir \
          --create-namespace \
          --kubeconfig="$CLUSTER_KUBECONFIG"
      fi

      # 8. argo-rollouts 설치 확인 및 설치
      if ! helm list -A --kubeconfig="$CLUSTER_KUBECONFIG" | grep "${each.value.environment}-${each.key}-argo-rollouts"; then
        helm upgrade --install ${each.value.environment}-${each.key}-argo-rollouts \
          poc-helm/argo-rollouts \
          --namespace argo-rollouts \
          --create-namespace \
          --kubeconfig="$CLUSTER_KUBECONFIG"
      fi

      # 9. ArgoCD에 클러스터 등록
      CLUSTER_NAME="${each.value.environment}-${each.key}"
      CLUSTER_FULL_NAME="nks_kr_poc-${each.value.environment}-${each.value.name}-k8s-${split("-", each.key)[1]}_${ncloud_nks_cluster.clusters[each.key].uuid}"

      if ! argocd cluster list | grep "$CLUSTER_NAME"; then
        echo "Adding cluster $CLUSTER_NAME to ArgoCD..."
        argocd cluster add "$CLUSTER_FULL_NAME" \
          --kubeconfig="$CLUSTER_KUBECONFIG" \
          --name="$CLUSTER_NAME" \
          --yes
      else
        echo "Cluster $CLUSTER_NAME is already registered in ArgoCD"
      fi

      # 10. 프록시 서버 설치 (필요시 cmn 클러스터 1번 노드에 설치)
      if [[ "${each.value.name}" == "cmn" && "${each.key}" == "1" ]]; then
        if ! kubectl get daemonset proxy-server --kubeconfig="$CLUSTER_KUBECONFIG" &> /dev/null; then
          echo "프록시 서버 설치 중..."
          
          # CA 인증서로 ConfigMap 생성
          kubectl --kubeconfig="$CLUSTER_KUBECONFIG" create configmap squid-cert --from-literal=ca.crt="$(kubectl --kubeconfig="$CLUSTER_KUBECONFIG" config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d)"
          
          # 프록시 서버 설치
          kubectl apply -f ${path.module}/manifest/proxy.yml --kubeconfig="$CLUSTER_KUBECONFIG"
        else
          echo "프록시 서버가 이미 설치되어 있습니다"
        fi
      fi
    EOT
  }

  depends_on = [
    ncloud_nks_cluster.clusters,
    local_file.cluster_info,
    local_file.node_info
  ]
} 
