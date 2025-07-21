#!/bin/bash

# Cloudflare配置
CF_API_TOKEN="你的CF_API_TOKEN"
CF_ZONE_ID="你的ZONE_ID"
CF_RECORD_NAME="aws1.9xyu.top"

# 获取本机公网IP
PUBLIC_IP=$(curl -s https://ipv4.icanhazip.com)

if [ -z "$PUBLIC_IP" ]; then
    echo "获取IP失败，尝试备用方法"
    PUBLIC_IP=$(curl -s https://api.ipify.org)
fi

if [ -z "$PUBLIC_IP" ]; then
    echo "无法获取公网IP"
    exit 1
fi

echo "当前公网IP: $PUBLIC_IP"

# 获取现有DNS记录
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?name=$CF_RECORD_NAME&type=A" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" | \
    grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$RECORD_ID" ]; then
    echo "DNS记录不存在，创建新记录"
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$CF_RECORD_NAME\",\"content\":\"$PUBLIC_IP\",\"ttl\":300}"
else
    echo "更新现有DNS记录"
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$CF_RECORD_NAME\",\"content\":\"$PUBLIC_IP\",\"ttl\":300}"
fi

echo "DNS更新完成: $CF_RECORD_NAME -> $PUBLIC_IP"
