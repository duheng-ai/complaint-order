#!/bin/bash

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}=== complaint-order 技能 自动安装 ===${NC}"

# 路径
OPENCLAW_DIR="$HOME/.openclaw"
SKILLS_DIR="$OPENCLAW_DIR/skills"
TARGET_DIR="$SKILLS_DIR/complaint-order"

# 检查 OpenClaw
if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${RED}错误：未找到 OpenClaw，请先安装主程序！${NC}"
    exit 1
fi

# 1. 创建目录
echo -e "${YELLOW}[1/4] 创建目录...${NC}"
mkdir -p "$TARGET_DIR"

# 2. 下载并解压
echo -e "${YELLOW}[2/4] 下载技能...${NC}"
cd "$HOME"
curl -L -o complaint-order.zip https://github.com/duheng-ai/complaint-order/archive/refs/heads/main.zip
unzip -o complaint-order.zip
cp -rf complaint-order-main/* "$TARGET_DIR/"
rm -rf complaint-order.zip complaint-order-main

# 3. 配置账号密码
echo -e "${YELLOW}[3/4] 配置账号密码${NC}"
read -p "请输入登录手机号: " phone
read -p "请输入登录密码: " password

# 自动生成配置文件
cat > "$TARGET_DIR/config.js" << EOF
module.exports = {
  LOGIN: {
    phone: "$phone",
    password: "$password"
  }
};
EOF

echo -e "${GREEN}✅ 账号配置完成${NC}"

# 4. 安装依赖
echo -e "${YELLOW}[4/4] 安装 npm 依赖...${NC}"
cd "$TARGET_DIR"
npm install --silent

echo -e "\n${GREEN}🎉 安装全部完成！${NC}"
echo -e "${CYAN}📁 路径：$TARGET_DIR${NC}"
echo -e "请重启 OpenClaw 网关即可使用！\n"
