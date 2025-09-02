#!/bin/bash

# 设置主机名
hostnamectl set-hostname ${hostname}

# 更新系统
apt-get update -y
apt-get upgrade -y

# 安装常用工具
apt-get install -y \
    htop \
    tmux \
    ncdu \
    nethogs \
    iotop \
    curl \
    wget \
    git \
    unzip \
    jq \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# 安装AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --update
rm -rf awscliv2.zip aws/

# 安装Session Manager Plugin
curl "https://s3.${region}.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
dpkg -i session-manager-plugin.deb
rm session-manager-plugin.deb

# 配置SSH
mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
chown ubuntu:ubuntu /home/ubuntu/.ssh

# 创建监控脚本
cat > /usr/local/bin/system-monitor << 'EOF'
#!/bin/bash
echo "=== System Overview ==="
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "=== Memory Usage ==="
free -h
echo "=== Disk Usage ==="
df -h /
echo "=== Top Processes ==="
ps aux --sort=-%cpu | head -10
EOF

chmod +x /usr/local/bin/system-monitor

# 设置crontab定期更新
echo "0 3 * * * apt-get update -y && apt-get upgrade -y" | crontab -

# 重启SSH服务以使更改生效
systemctl restart sshd

echo "Bastion host initialization complete for ${environment} environment"