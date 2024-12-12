#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

NODE_INFO=$(cat "${PROJECT_ROOT}/node_info.json")
ACG_ID=$(echo "$NODE_INFO" | jq -r '.acg.id')
ACG_NAME=$(echo "$NODE_INFO" | jq -r '.acg.name')

log "ACG 적용 프로세스 시작: $ACG_NAME ($ACG_ID)"

for cluster in $(echo "$NODE_INFO" | jq -r '.nodes | keys[]'); do
    log "클러스터 처리 중: $cluster"
    
    node_count=$(echo "$NODE_INFO" | jq -r ".nodes[\"$cluster\"].nodes | length")
    for i in $(seq 0 $(($node_count - 1))); do
        node_json=$(echo "$NODE_INFO" | jq -r ".nodes[\"$cluster\"].nodes[$i]")
        node_name=$(echo "$node_json" | jq -r '.name')
        server_instance_no=$(echo "$node_json" | jq -r '.server_instance_no')
        
        log "노드 확인 중: $node_name"
        
        nic_list=$(ncloud vserver getNetworkInterfaceList --instanceNo "$server_instance_no")
        
        primary_nic_no=$(echo "$nic_list" | jq -r '.getNetworkInterfaceListResponse.networkInterfaceList[0].networkInterfaceNo')
        acg_list=$(echo "$nic_list" | jq -r '.getNetworkInterfaceListResponse.networkInterfaceList[0].accessControlGroupNoList[]')
        
        if echo "$acg_list" | grep -q "^${ACG_ID}$"; then
            log "이미 ACG가 적용됨: $node_name"
            continue
        fi
        
        ncloud vserver addNetworkInterfaceAccessControlGroup \
            --networkInterfaceNo "$primary_nic_no" \
            --accessControlGroupNoList "$ACG_ID" && \
            log "ACG 적용 완료: $node_name"
        
        sleep 1
    done
done

log "ACG 적용 프로세스 완료"