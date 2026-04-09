# complaint-order Skill Installer
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1

Write-Host "Starting complaint-order skill installation..." -ForegroundColor Green

# Configuration
$SkillName = "complaint-order"
$RepoUrl = "https://github.com/duheng-ai/complaint-order.git"
$OpenClawSkillsDir = "$env:USERPROFILE\.openclaw\workspace\skills"
$TempDir = "$env:TEMP\$SkillName-install"

# Step 1: Check OpenClaw directory
Write-Host "`nChecking OpenClaw directory..." -ForegroundColor Cyan
if (-not (Test-Path $OpenClawSkillsDir)) {
    Write-Host "Error: OpenClaw skills directory not found: $OpenClawSkillsDir" -ForegroundColor Red
    Write-Host "Please make sure OpenClaw is installed" -ForegroundColor Yellow
    exit 1
}
Write-Host "OpenClaw skills directory found" -ForegroundColor Green

# Step 2: Backup old version if exists
$SkillDir = Join-Path $OpenClawSkillsDir $SkillName
if (Test-Path $SkillDir) {
    Write-Host "`nOld version found, backing up..." -ForegroundColor Yellow
    $BackupDir = "$SkillDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $SkillDir -Destination $BackupDir -Force
    Write-Host "Backup saved to: $BackupDir" -ForegroundColor Green
}

# Step 3: Clone repository
Write-Host "`nCloning repository..." -ForegroundColor Cyan
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}
git clone $RepoUrl $TempDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "Clone failed" -ForegroundColor Red
    exit 1
}
Write-Host "Repository cloned" -ForegroundColor Green

# Step 4: Install skill
Write-Host "`nInstalling skill..." -ForegroundColor Cyan
Move-Item -Path $TempDir -Destination $SkillDir -Force
Write-Host "Skill installed to: $SkillDir" -ForegroundColor Green

# Step 5: Install dependencies
Write-Host "`nInstalling dependencies..." -ForegroundColor Cyan
Set-Location $SkillDir
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: npm install failed, please run manually: npm install" -ForegroundColor Yellow
} else {
    Write-Host "Dependencies installed" -ForegroundColor Green
}

# Step 6: Cleanup
Write-Host "`nCleaning up..." -ForegroundColor Cyan
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}

# Step 7: Configuration instructions
Write-Host "`nConfiguration required:" -ForegroundColor Cyan
Write-Host "Please edit the following file and configure your account:" -ForegroundColor Yellow
Write-Host "  $SkillDir\index.js" -ForegroundColor White
Write-Host "`nFind CONFIG section and modify:" -ForegroundColor Yellow
Write-Host "  phone: `"your_phone_number`"" -ForegroundColor White
Write-Host "  password: `"your_password`"" -ForegroundColor White

# Step 8: Restart gateway
Write-Host "`nRestart OpenClaw gateway:" -ForegroundColor Cyan
Write-Host "  openclaw gateway restart" -ForegroundColor White

# Completion
Write-Host "`nInstallation completed!" -ForegroundColor Green
Write-Host "`nUsage:" -ForegroundColor Cyan
Write-Host "Send messages containing these keywords to trigger:" -ForegroundColor Yellow
Write-Host "  - 联系方式 (contact)" -ForegroundColor White
Write-Host "  - 投诉内容 (complaint)" -ForegroundColor White
Write-Host "  - 订单号 (order number)" -ForegroundColor White
Write-Host "`nExample:" -ForegroundColor Cyan
Write-Host "  用户投诉内容：充值 249 元，网卡的不行" -ForegroundColor White
Write-Host "  用户联系方式：18876509647" -ForegroundColor White
Write-Host "  订单号：4200003034202603317170467000" -ForegroundColor White
Write-Host "`nEnjoy!" -ForegroundColor Green
