# complaint-order 鎶€鑳藉畨瑁呰剼鏈?# 浣跨敤鏂规硶锛歱owershell -ExecutionPolicy Bypass -File install.ps1
# 缂栫爜锛歎TF-8 with BOM

Write-Host "Starting complaint-order skill installation..." -ForegroundColor Green

# 閰嶇疆
$SkillName = "complaint-order"
$RepoUrl = "https://github.com/duheng-ai/complaint-order.git"
$OpenClawSkillsDir = "$env:USERPROFILE\.openclaw\workspace\skills"
$TempDir = "$env:TEMP\$SkillName-install"

# 1. 妫€鏌?OpenClaw 鐩綍
Write-Host "`nChecking OpenClaw directory..." -ForegroundColor Cyan
if (-not (Test-Path $OpenClawSkillsDir)) {
    Write-Host "Error: OpenClaw skills directory not found: $OpenClawSkillsDir" -ForegroundColor Red
    Write-Host "Please make sure OpenClaw is installed" -ForegroundColor Yellow
    exit 1
}
Write-Host "OpenClaw skills directory found" -ForegroundColor Green

# 2. 娓呯悊鏃х増鏈?$SkillDir = Join-Path $OpenClawSkillsDir $SkillName
if (Test-Path $SkillDir) {
    Write-Host "`nOld version found, backing up..." -ForegroundColor Yellow
    $BackupDir = "$SkillDir-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -Path $SkillDir -Destination $BackupDir -Force
    Write-Host "Backup saved to: $BackupDir" -ForegroundColor Green
}

# 3. 鍏嬮殕浠撳簱
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

# 4. 绉诲姩鍒?skills 鐩綍
Write-Host "`nInstalling skill..." -ForegroundColor Cyan
Move-Item -Path $TempDir -Destination $SkillDir -Force
Write-Host "Skill installed to: $SkillDir" -ForegroundColor Green

# 5. 瀹夎渚濊禆
Write-Host "`nInstalling dependencies..." -ForegroundColor Cyan
Set-Location $SkillDir
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: npm install failed, please run manually: npm install" -ForegroundColor Yellow
} else {
    Write-Host "Dependencies installed" -ForegroundColor Green
}

# 6. 娓呯悊涓存椂鏂囦欢
Write-Host "`nCleaning up..." -ForegroundColor Cyan
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}

# 7. 閰嶇疆鎻愮ず
Write-Host "`nConfiguration required:" -ForegroundColor Cyan
Write-Host "Please edit the following file and configure your account:" -ForegroundColor Yellow
Write-Host "  $SkillDir\index.js" -ForegroundColor White
Write-Host "`nFind CONFIG section and modify:" -ForegroundColor Yellow
Write-Host "  phone: `"your_phone_number`"" -ForegroundColor White
Write-Host "  password: `"your_password`"" -ForegroundColor White

# 8. 閲嶅惎缃戝叧鎻愮ず
Write-Host "`nRestart OpenClaw gateway:" -ForegroundColor Cyan
Write-Host "  openclaw gateway restart" -ForegroundColor White

# 瀹屾垚
Write-Host "`nInstallation completed!" -ForegroundColor Green
Write-Host "`nUsage:" -ForegroundColor Cyan
Write-Host "Send messages containing these keywords to trigger:" -ForegroundColor Yellow
Write-Host "  - 鑱旂郴鏂瑰紡 (contact)" -ForegroundColor White
Write-Host "  - 鎶曡瘔鍐呭 (complaint)" -ForegroundColor White
Write-Host "  - 璁㈠崟鍙?(order number)" -ForegroundColor White
Write-Host "`nExample:" -ForegroundColor Cyan
Write-Host "  鐢ㄦ埛鎶曡瘔鍐呭锛氬厖鍊?249 鍏冿紝缃戝崱鐨勪笉琛? -ForegroundColor White
Write-Host "  鐢ㄦ埛鑱旂郴鏂瑰紡锛?8876509647" -ForegroundColor White
Write-Host "  璁㈠崟鍙凤細4200003034202603317170467000" -ForegroundColor White
Write-Host "`nEnjoy!" -ForegroundColor Green
