param(
  [string]$Edge = "${env:ProgramFiles(x86)}/Microsoft/Edge/Application/msedge.exe",
  [uri]$Url
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$studio = Join-Path $root 'studio/index.html'
$engine = Join-Path $root 'studio/engine.js'
if (-not $Url -and -not (Test-Path -LiteralPath $engine)) {
  throw 'Build the Studio with node scripts/build-studio.mjs first.'
}
$probe = "edge-$([guid]::NewGuid())"
$run = Join-Path $root "_build/$probe"
New-Item -ItemType Directory -Path $run -Force | Out-Null
$testPage = if ($Url) { $Url } else { [uri]$studio }
$page = $testPage.GetLeftPart([UriPartial]::Path) + '?probe'
$dom = Join-Path $run 'dom.log'
$stderr = Join-Path $run 'stderr.log'
$profile = Join-Path $run 'profile'
$process = Start-Process -FilePath $Edge -ArgumentList @(
  '--headless=new', '--disable-gpu', '--disable-background-networking',
  '--no-first-run', ('--user-data-dir="' + $profile + '"'), '--window-size=420,850',
  '--virtual-time-budget=10000', '--dump-dom', ('"' + $page + '"')
) -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput $dom -RedirectStandardError $stderr
if ($process.ExitCode -ne 0 -or -not (Select-String -SimpleMatch 'data-probe="passed"' -LiteralPath $dom -Quiet)) {
  throw "Studio browser probe failed. Logs: $run"
}
Write-Output "Studio browser probe PASS. Logs: $run"
