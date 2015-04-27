#!/bin/bash

OPTS=`getopt --options h:p:o:t:e:d: --longoptions meshblu-host:,meshblu-port:,owner-uuid:,type:,etcd-peer:,etcd-dir: --name 'run.sh' -- "$@"`
eval set -- "$OPTS"

while true; do
  case "$1" in
    -h | --meshblu-host ) MESHBLU_HOST=$2; shift 2 ;;
    -p | --meshblu-port ) MESHBLU_PORT=$2; shift 2 ;;
    -o | --owner-uuid ) OWNER_UUID=$2; shift 2 ;;
    -t | --type ) DEVICE_TYPE=$2; shift 2 ;;
    -e | --etcd-peer ) ETCD_PEER=$2; shift 2 ;;
    -d | --etcd-dir ) ETCD_DIR=$2; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

meshblu-util register --server $MESHBLU_HOST:$MESHBLU_PORT --data "{\"type\":\"$DEVICE_TYPE\",\"owner\":\"$OWNER_UUID\",\"discoverWhitelist\": [\"$OWNER_UUID\"],\"configureWhitelist\": [\"$OWNER_UUID\"],\"sendWhitelist\": [\"$OWNER_UUID\"],\"receiveWhitelist\": [\"$OWNER_UUID\"]}" > meshblu.json

# cat meshblu.json | jq '.'

DEVICE_UUID=$(cat meshblu.json | jq -r '.uuid')
DEVICE_TOKEN=$(cat meshblu.json | jq -r '.token')

# echo "DEVICE_UUID: $DEVICE_UUID"
# echo "DEVICE_TOKEN: $DEVICE_TOKEN"

export ETCDCTL_PEERS=$ETCD_PEER
etcdctl set $ETCD_DIR/uuid $DEVICE_UUID
etcdctl set $ETCD_DIR/token $DEVICE_TOKEN
