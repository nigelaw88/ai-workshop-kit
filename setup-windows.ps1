# ==============================================================================
# Agentic AI Workshop - Windows 10/11 Setup Kit (Zero-Admin, x64 & ARM64)
# Compatible with Windows PowerShell 5.1 and PowerShell 7+
# Installs:
#   1. OpenCode v2 (standalone native binary in %USERPROFILE%\.opencode\bin)
#   2. uv + standalone Python 3.12 (in %USERPROFILE%\.local\bin)
#   3. Creates Desktop\ai-workshop starter folder
#   4. Runs a Pre-Flight Check you can screenshot for the organizer
# ==============================================================================
$ErrorActionPreference = "Stop"

# Ensure TLS 1.2 for older Windows 10 / PowerShell 5.1 hosts
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "   Agentic AI Workshop - Windows Pre-Flight Setup" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Allow local scripts in CurrentUser scope (avoids common PowerShell policy blocks)
try {
    $policy = Get-ExecutionPolicy -Scope CurrentUser
    if ($policy -eq "Restricted" -or $policy -eq "Undefined") {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    }
} catch {
    Write-Host "  (Skipping ExecutionPolicy change - managed by IT policy)" -ForegroundColor Yellow
}

$OpenCodeBin = Join-Path $env:USERPROFILE ".opencode\bin"
$UvBin       = Join-Path $env:USERPROFILE ".local\bin"

function Add-ToUserPath {
    param([string]$Dir)
    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $currentUserPath) { $currentUserPath = "" }

    # Auto-repair any missing-semicolon concatenation from an earlier run
    $currentUserPath = $currentUserPath -replace '(?<!^|;)([A-Za-z]:\\)', ';$1'

    # Force array with @(...) so single-entry Paths don't string-concatenate on '+'
    $parts = @($currentUserPath -split ";" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
    $cleanParts = @()
    foreach ($p in $parts) {
        if ($cleanParts -notcontains $p) { $cleanParts += $p }
    }
    if ($cleanParts -notcontains $Dir) {
        $cleanParts += $Dir
    }

    $newPath = $cleanParts -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")

    $procParts = @($env:Path -split ";" | Where-Object { $_ -ne "" })
    if ($procParts -notcontains $Dir) {
        $env:Path = "$Dir;$env:Path"
    }
}

# 1. Install OpenCode v2 (standalone binary - auto-detects x64 vs ARM64, no Admin needed)
Write-Host "[1/3] Installing OpenCode..." -ForegroundColor White
New-Item -ItemType Directory -Force -Path $OpenCodeBin | Out-Null
$OpenCodeExe = Join-Path $OpenCodeBin "opencode.exe"

if (Test-Path $OpenCodeExe) {
    Add-ToUserPath $OpenCodeBin
    $existingVer = (& $OpenCodeExe --version 2>&1) | Out-String
    Write-Host "  Already installed: $($existingVer.Trim())" -ForegroundColor Green
} else {
    $rawArch = $env:PROCESSOR_ARCHITECTURE
    if ($env:PROCESSOR_ARCHITEW6432) { $rawArch = $env:PROCESSOR_ARCHITEW6432 }
    if ($rawArch -and $rawArch.ToLower() -match "arm64") {
        $arch = "arm64"
        $pkg  = "@opencode/cli-windows-arm64"
    } else {
        $arch = "x64"
        $pkg  = "@opencode/cli-windows-x64"
    }
    Write-Host "  Detected architecture: $arch ($pkg)" -ForegroundColor DarkGray

    $meta = Invoke-RestMethod -Uri "https://registry.npmjs.org/$pkg/latest"
    $tarballUrl = $meta.dist.tarball
    $tmpDir = Join-Path $env:TEMP ("opencode-setup-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
    $tgzPath = Join-Path $tmpDir "opencode.tgz"

    try {
        Write-Host "  Downloading OpenCode v$($meta.version)..." -ForegroundColor DarkGray
        $prevProgress = $ProgressPreference
        $ProgressPreference = "SilentlyContinue"
        Invoke-WebRequest -Uri $tarballUrl -OutFile $tgzPath -UseBasicParsing
        $ProgressPreference = $prevProgress

        & tar.exe -xzf $tgzPath -C $tmpDir
        $foundExe = Get-ChildItem -Path $tmpDir -Recurse -Filter "opencode.exe" | Select-Object -First 1
        if (-not $foundExe) {
            throw "Could not locate opencode.exe inside downloaded archive."
        }
        Copy-Item -Path $foundExe.FullName -Destination $OpenCodeExe -Force
        Add-ToUserPath $OpenCodeBin
        Write-Host "  Installed OpenCode v$($meta.version) to $OpenCodeExe" -ForegroundColor Green
    } finally {
        Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 2. Install uv + standalone Python 3.12 (zero Admin)
Write-Host ""
Write-Host "[2/3] Installing uv & standalone Python 3.12..." -ForegroundColor White
Add-ToUserPath $UvBin

if (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host "  uv already installed: $(uv --version)" -ForegroundColor Green
} else {
    Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
    Add-ToUserPath $UvBin
}

& uv python install 3.12

# 3. Create clean workshop folder
Write-Host ""
Write-Host "[3/3] Creating workshop workspace folder..." -ForegroundColor White
$DesktopDir  = [Environment]::GetFolderPath("Desktop")
$WorkshopDir = Join-Path $DesktopDir "ai-workshop"
New-Item -ItemType Directory -Force -Path $WorkshopDir | Out-Null
Write-Host "  Ready: $WorkshopDir" -ForegroundColor Green

# ==============================================================================
# Pre-Flight Verification
# ==============================================================================
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "               PRE-FLIGHT CHECK SUMMARY" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

$allOk = $true

try {
    $ocVer = (& opencode --version 2>&1) | Out-String
    Write-Host "  [OK] OpenCode:   $($ocVer.Trim())" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] OpenCode: Not found" -ForegroundColor Red
    $allOk = $false
}

try {
    $uvVer = (& uv --version 2>&1) | Out-String
    Write-Host "  [OK] uv:         $($uvVer.Trim())" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] uv:       Not found" -ForegroundColor Red
    $allOk = $false
}

try {
    $pyVer = (& uv run --python 3.12 python --version 2>&1) | Out-String
    Write-Host "  [OK] Python:     $($pyVer.Trim()) (via uv)" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Python:   Failed to run via uv" -ForegroundColor Red
    $allOk = $false
}

Write-Host "  [OK] Workspace:  $WorkshopDir" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan

if ($allOk) {
    Write-Host ""
    Write-Host "ALL READY FOR THE WORKSHOP!" -ForegroundColor Green
    Write-Host "Please take a screenshot of this summary and send it to the organizer."
    Write-Host "Note: Close and reopen PowerShell/Terminal once before running 'opencode'." -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Some checks failed. Please screenshot this output and share it with the organizer." -ForegroundColor Red
    Write-Host ""
    exit 1
}
