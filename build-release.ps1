# Creates the signing keystore (first run only) and publishes a signed release APK.
# Usage (from the TvClock folder):  powershell -ExecutionPolicy Bypass -File .\build-release.ps1
$ErrorActionPreference = 'Stop'

$projectDir = $PSScriptRoot
$keystore   = Join-Path (Split-Path $projectDir -Parent) 'tvclock.keystore'   # matches TvClock.csproj
$alias      = 'tvclock'

# Locate keytool (PATH, then the Microsoft JDK installed by Visual Studio)
$keytool = (Get-Command keytool -ErrorAction SilentlyContinue).Source
if (-not $keytool) {
	$keytool = Get-ChildItem 'C:\Program Files\Microsoft\jdk-*\bin\keytool.exe', 'C:\Program Files\Android\openjdk\*\bin\keytool.exe' -ErrorAction SilentlyContinue |
			   Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $keytool) { throw 'keytool.exe not found. Install the JDK via the Visual Studio Installer.' }

# Ask for the password (used for both the store and the key)
$secure = Read-Host 'Keystore password (min 6 chars)' -AsSecureString
$pass   = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
if ($pass.Length -lt 6) { throw 'Password must be at least 6 characters.' }

if (-not (Test-Path $keystore)) {
	Write-Host "Creating keystore at $keystore"
	& $keytool -genkeypair -v -keystore $keystore -alias $alias -keyalg RSA -keysize 2048 -validity 10000 `
		-storepass $pass -keypass $pass -dname 'CN=TvClock, O=Personal, C=US'
	if ($LASTEXITCODE -ne 0) { throw 'keytool failed.' }
	Write-Host 'IMPORTANT: back up tvclock.keystore and its password. Updates require the same key.' -ForegroundColor Yellow
} else {
	Write-Host "Using existing keystore $keystore"
}

$env:TVCLOCK_KEYSTORE_PASS = $pass
try {
	dotnet publish (Join-Path $projectDir 'TvClock.csproj') -f net10.0-android -c Release
	if ($LASTEXITCODE -ne 0) { throw 'dotnet publish failed.' }
} finally {
	Remove-Item Env:TVCLOCK_KEYSTORE_PASS -ErrorAction SilentlyContinue
}

$apk = Get-ChildItem (Join-Path $projectDir 'bin\Release\net10.0-android\publish') -Filter '*-Signed.apk' | Select-Object -First 1
Write-Host "Signed APK: $($apk.FullName)" -ForegroundColor Green
