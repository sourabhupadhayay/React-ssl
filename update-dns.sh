#!/bin/bash
DOMAIN="dev.4xexch.com"
IP=$(curl -s http://checkip.amazonaws.com/)
ZONE_ID="Z05874792AIIDGGJ4T4WU"

cat > record.json <<EOF
{
  "Comment": "Update record set",
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "$DOMAIN",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{ "Value": "$IP" }]
    }
  }]
}
EOF

aws route53 change-resource-record-sets \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch file://record.json
