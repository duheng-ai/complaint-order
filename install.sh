#!/bin/bash

# complaint-order 技能安装脚本
# 使用方法：bash install.sh

echo "🚀 开始安装 complaint-order 技能..."

# 配置
SKILL_NAME="complaint-order"
REPO_URL="https://github.com/duheng-ai/complaint-order.git"
OPENCLAW_SKILLS_DIR="$HOME/.openclaw/workspace/skills"
TEMP_DIR="/tmp/$SKILL_NAME-install"

# 1. 检查 OpenClaw 目录
echo -e "\n📁 检查 OpenClaw 目录..."
if [ ! -d "$OPENCLAW_SKILLS_DIR" ]; then
    echo "❌ 未找到 OpenClaw skills 目录：$OPENCLAW_SKILLS_DIR"
    echo "请确认已安装 OpenClaw"
    exit 1
fi
echo "✅ OpenClaw skills 目录存在"

# 2. 清理旧版本
SKILL_DIR="$OPENCLAW_SKILLS_DIR/$SKILL_NAME"
if [ -d "$SKILL_DIR" ]; then
    echo -e "\n🗑️  发现旧版本，正在备份..."
    BACKUP_DIR="$SKILL_DIR-backup-$(date +%Y%m%d-%H%M%S)"
    mv "$SKILL_DIR" "$BACKUP_DIR"
    echo "✅ 旧版本已备份至：$BACKUP_DIR"
fi

# 3. 克隆仓库
echo -e "\n📥 克隆仓库..."
rm -rf "$TEMP_DIR"
git clone "$REPO_URL" "$TEMP_DIR"
if [ $? -ne 0 ]; then
    echo "❌ 克隆失败"
    exit 1
fi
echo "✅ 仓库克隆完成"

# 4. 移动到 skills 目录
echo -e "\n📦 安装技能..."
mv "$TEMP_DIR" "$SKILL_DIR"
echo "✅ 技能已安装至：$SKILL_DIR"

# 5. 安装依赖
echo -e "\n🔧 安装依赖..."
cd "$SKILL_DIR"
npm install
if [ $? -ne 0 ]; then
    echo "⚠️  依赖安装失败，请手动执行：npm install"
else
    echo "✅ 依赖安装完成"
fi

# 6. 清理临时文件
echo -e "\n🧹 清理临时文件..."
rm -rf "$TEMP_DIR"

# 7. 配置提示
echo -e "\n⚙️  配置账号密码..."
echo "请编辑以下文件，修改火脸运营后台账号："
echo "  $SKILL_DIR/index.js"
echo -e "\n找到 CONFIG 部分，修改："
echo "  phone: \"您的手机号\""
echo "  password: \"您的密码\""

# 8. 重启网关提示
echo -e "\n🔄 重启 OpenClaw 网关..."
echo "请执行以下命令重启网关："
echo "  openclaw gateway restart"

# 完成
echo -e "\n✅ 安装完成！"
echo -e "\n📚 使用说明："
echo "发送包含以下关键词的消息即可触发："
echo "  - 联系方式"
echo "  - 投诉内容"
echo "  - 订单号"
echo -e "\n示例："
echo "  用户投诉内容：充值 249 元，网卡的不行"
echo "  用户联系方式：18876509647"
echo "  订单号：4200003034202603317170467000"
echo -e "\n🎉 祝你使用愉快！"
