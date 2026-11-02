
#!/bin/bash
set -e

APP_DIR="/home/ubuntu/mysafety-health-demo"

# Install Node.js 22 if missing
if ! command -v node >/dev/null 2>&1; then
    apt-get update
    apt-get install -y curl
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
fi

# Install Nginx and PM2
apt-get update
apt-get install -y nginx
npm install -g pm2

# Set project permissions
chown -R ubuntu:ubuntu "$APP_DIR"

# Install production dependencies and start the API
sudo -u ubuntu -H bash -c '
cd /home/ubuntu/mysafety-health-demo
npm install --omit=dev

if pm2 describe mysafety-health >/dev/null 2>&1; then
    pm2 restart mysafety-health
else
    pm2 start dist-health/health.js --name mysafety-health
fi

pm2 save
'

# Configure Nginx
cat > /etc/nginx/sites-available/mysafety-health <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/mysafety-health /etc/nginx/sites-enabled/mysafety-health
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable --now nginx
systemctl reload nginx
