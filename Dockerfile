# Stage 1: Build React app
FROM node:18-alpine AS builder

WORKDIR /app
COPY . .
RUN npm install && npm run build

# Stage 2: Serve with Nginx and SSL
FROM nginx:alpine

# Create folder for SSL certs
RUN mkdir -p /etc/nginx/ssl

# Copy built React app
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom Nginx config (with SSL)
COPY nginx.conf /etc/nginx/nginx.conf

