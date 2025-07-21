#!/bin/bash

echo "开始安装和配置 XrayR 服务..."

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 权限运行此脚本"
    echo "使用命令: sudo bash xrayr.sh"
    exit 1
fi

# 步骤1: 一键安装 XrayR
echo "步骤1: 正在安装 XrayR..."
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

# 检查安装是否成功
if [ $? -ne 0 ]; then
    echo "XrayR 安装失败，请检查网络连接或重试"
    exit 1
fi

echo "XrayR 安装完成"

# 步骤2: 下载并解压配置文件
echo "步骤2: 正在下载配置文件..."

# 创建临时目录
TEMP_DIR="/tmp/xrayr_config"
mkdir -p "$TEMP_DIR"

# 下载 config.zip 文件
echo "正在从 GitHub 仓库下载 config.zip..."
curl -L -o "$TEMP_DIR/config.zip" "https://github.com/Rainchen537/awssh/raw/main/config.zip"

# 检查下载是否成功
if [ ! -f "$TEMP_DIR/config.zip" ]; then
    echo "配置文件下载失败，请检查网络连接或文件路径"
    exit 1
fi

echo "配置文件下载完成"

# 步骤3: 解压配置文件到 XrayR 目录
echo "步骤3: 正在解压配置文件到 /etc/XrayR/..."

# 确保目标目录存在
mkdir -p /etc/XrayR

# 解压配置文件
unzip -o "$TEMP_DIR/config.zip" -d /etc/XrayR/

# 检查解压是否成功
if [ $? -ne 0 ]; then
    echo "配置文件解压失败"
    exit 1
fi

# 检查 config.json 是否存在
if [ ! -f "/etc/XrayR/config.yml" ]; then
    echo "警告: /etc/XrayR/config.yml 文件不存在，请检查压缩包内容"
fi

echo "配置文件解压完成"

# 清理临时文件
echo "清理临时文件..."
rm -rf "$TEMP_DIR"

# 设置正确的文件权限
echo "设置文件权限..."
chmod 644 /etc/XrayR/config.json
chown root:root /etc/XrayR/config.json

echo "XrayR 服务安装和配置完成！"
echo ""
echo "接下来的步骤："
echo "1. 编辑配置文件: nano /etc/XrayR/config.json"
echo "2. 启动服务: systemctl start XrayR"
echo "3. 设置开机自启: systemctl enable XrayR"
echo "4. 查看服务状态: systemctl status XrayR"
echo "5. 查看日志: journalctl -u XrayR -f"
