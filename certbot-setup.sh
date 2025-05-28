#!/bin/bash
DOMAIN="dev.4xexch.com"
EMAIL="sourbhupadhayay@gmail.com"

# Stop any container that might be using port 80 (like nginx)
docker ps --filter "publish=80" --format "{{.ID}}" | xargs -r docker stop

# Run certbot in standalone mode via Docker
docker run --rm -p 80:80 \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/lib/letsencrypt:/var/lib/letsencrypt \
  certbot/certbot certonly --standalone \
  -d "$DOMAIN" --agree-tos --email "$EMAIL" --non-interactive
