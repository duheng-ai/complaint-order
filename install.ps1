# complaint-order 技能安装脚本
# 使用方法：powershell -ExecutionPolicy Bypass -File install.ps1

Write-Host "🚀 开始安装 complaint-order 技能..." -ForegroundColor Green

# 配置
$SkillName = "complaint-order"
$RepoUrl = "https://github.com/duheng-ai/complaint-order.git"
$OpenClawSkillsDir = "$env:USERPROFILE\.openclaw\workspace\skills"
$TempDir = "$env:TEMP\$SkillName-install"

# 1. 检查 OpenClaw 目录
Write-Host "`n📁 检查 OpenClaw 目录..." -ForegroundColor Cyan
if (-not (Test-Path $OpenClawSkillsDir)) {
    Write-Host "❌ 未找到 OpenClaw skills 目录：$OpenClawSkillsDir" -ForegroundColor Red
    Write-Host "请确认已安装 OpenClaw" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ OpenClaw skills 目录存在" -ForegroundColor Green

# 2. 清理旧版本
$SkillDir = Join-Path $OpenClawSkillsDir $SkillName
if (Test-Path $SkillDir) {
    Write-Host "`n🗑️  发现旧版本，正在备份..." -ForegroundColor Yellow
    $BackupDir = "$SkillDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $SkillDir -Destination $BackupDir -Force
    Write-Host "✅ 旧版本已备份至：$BackupDir" -ForegroundColor Green
}

# 3. 克隆仓库
Write-Host "`n📥 克隆仓库..." -ForegroundColor Cyan
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}
git clone $RepoUrl $TempDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 克隆失败" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 仓库克隆完成" -ForegroundColor Green

# 4. 移动到 skills 目录
Write-Host "`n📦 安装技能..." -ForegroundColor Cyan
Move-Item -Path $TempDir -Destination $SkillDir -Force
Write-Host "✅ 技能已安装至：$SkillDir" -ForegroundColor Green

# 5. 安装依赖
Write-Host "`n🔧 安装依赖..." -ForegroundColor Cyan
Set-Location $SkillDir
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  依赖安装失败，请手动执行：npm install" -ForegroundColor Yellow
} else {
    Write-Host "✅ 依赖安装完成" -ForegroundColor Green
}

# 6. 清理临时文件
Write-Host "`n🧹 清理临时文件..." -ForegroundColor Cyan
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}

# 7. 配置提示
Write-Host "`n⚙️  配置账号密码..." -ForegroundColor Cyan
Write-Host "请编辑以下文件，修改火脸运营后台账号：" -ForegroundColor Yellow
Write-Host "  $SkillDir\index.js" -ForegroundColor White
Write-Host "`n找到 CONFIG 部分，修改：" -ForegroundColor Yellow
Write-Host "  phone: `"您的手机号`"" -ForegroundColor White
Write-Host "  password: `"您的密码`"" -ForegroundColor White

# 8. 重启网关提示
Write-Host "`n🔄 重启 OpenClaw 网关..." -ForegroundColor Cyan
Write-Host "请执行以下命令重启网关：" -ForegroundColor Yellow
Write-Host "  openclaw gateway restart" -ForegroundColor White

# 完成
Write-Host "`n✅ 安装完成！" -ForegroundColor Green
Write-Host "`n📚 使用说明：" -ForegroundColor Cyan
Write-Host "发送包含以下关键词的消息即可触发：" -ForegroundColor Yellow
Write-Host "  - 联系方式" -ForegroundColor White
Write-Host "  - 投诉内容" -ForegroundColor White
Write-Host "  - 订单号" -ForegroundColor White
Write-Host "`n示例：" -ForegroundColor Cyan
Write-Host "  用户投诉内容：充值 249 元，网卡的不行" -ForegroundColor White
Write-Host "  用户联系方式：18876509647" -ForegroundColor White
Write-Host "  订单号：4200003034202603317170467000" -ForegroundColor White
Write-Host "`n🎉 祝你使用愉快！" -ForegroundColor Green
