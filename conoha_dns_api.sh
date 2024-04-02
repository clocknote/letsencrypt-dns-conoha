#!/bin/bash

# -------- #
# VARIABLE #
# -------- #
SCRIPT_PATH=$(dirname $(readlink -f $0))
source ${SCRIPT_PATH}/.env

# -------- #
# FUNCTION #
# -------- #

# アクセストークンを取得して標準出力に返す関数
get_conoha_token(){
  curl -sS ${CNH_IDENTITY_ENDPOINT}/auth/tokens \
  -X POST \
  -H "Accept: application/json" \
  -d '{"auth":{"identity":{"methods":["password"],"password":{"user":{"name":"'${CNH_USERNAME}'","password":"'${CNH_PASSWORD}'"}}},"scope":{"project":{"id":"'${CNH_TENANT_ID}'"}}}}' \
  -o /dev/null \
  -w "%header{X-Subject-Token}"
}


get_conoha_domain_id(){
  curl -sS ${CNH_DNS_ENDPOINT}/v1/domains \
  -X GET \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CNH_TOKEN}" \
  | jq -r '.domains[] | select(.name == "'${CNH_DNS_DOMAIN_ROOT}'") | .id'
}

create_conoha_dns_record(){
  curl -sS ${CNH_DNS_ENDPOINT}/v1/domains/${CNH_DOMAIN_ID}/records \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CNH_TOKEN}" \
  -d '{ "name": "'${CNH_DNS_NAME}'", "type": "'${CNH_DNS_TYPE}'", "data": "'${CNH_DNS_DATA}'", "ttl": 60 }'
}

get_conoha_dns_record_id(){
  curl -sS ${CNH_DNS_ENDPOINT}/v1/domains/${CNH_DOMAIN_ID}/records \
  -X GET \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CNH_TOKEN}" \
  | jq -r '.records[] | select(.name == "'${CNH_DNS_NAME}'" and .data == "'${CNH_DNS_DATA}'") | .id'
}

delete_conoha_dns_record(){
  local delete_id=$1
  curl -sS ${CNH_DNS_ENDPOINT}/v1/domains/${CNH_DOMAIN_ID}/records/${delete_id} \
  -X DELETE \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CNH_TOKEN}"
}

# ----------- #
# GET A TOKEN #
# ----------- #
echo Get ConoHa Token...
CNH_TOKEN=$(get_conoha_token)
echo ${CNH_TOKEN}

# ----------------- #
# GET THE DOMAIN ID #
# ----------------- #
echo Get Domain ID...
CNH_DOMAIN_ID=$(get_conoha_domain_id)
echo ${CNH_DOMAIN_ID}
