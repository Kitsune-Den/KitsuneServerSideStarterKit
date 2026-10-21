# Builds the Kitsune Server Side Starter Kit zip from each mod's GitHub release.
#
#   powershell -ExecutionPolicy Bypass -File build.ps1
#   powershell -ExecutionPolicy Bypass -File build.ps1 -Manifest test.json -OutDir C:\temp\kit
#
# Needs the GitHub CLI (gh), signed in. Every mod is pinned in kit.json to a
# release tag and asset; the build fails if an asset is missing or its
# ModInfo.xml version doesn't match.

param(
    [string]$Manifest = (Join-Path $PSScriptRoot 'kit.json'),
    [string]$OutDir   = (Join-Path $PSScriptRoot 'dist')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$utf8  = New-Object System.Text.UTF8Encoding $false
$kit   = Get-Content $Manifest -Raw | ConvertFrom-Json
$name  = "$($kit.name)-v$($kit.version)"
$stage = Join-Path $OutDir $name
$cache = Join-Path $OutDir '.cache'
$zip   = Join-Path $OutDir "$name.zip"

function Fail([string]$msg) { Write-Host "FAILED: $msg" -ForegroundColor Red; exit 1 }

# Runs gh. PowerShell 5.1 turns anything gh writes to stderr into a
# terminating error under 'Stop', so callers check $LASTEXITCODE instead.
function Invoke-Gh {
    $ErrorActionPreference = 'Continue'
    & gh @args 2>$null
}

# Downloads one release asset into the cache and returns its path.
function Get-Asset($mod) {
    $dir  = Join-Path (Join-Path $cache $mod.repo) $mod.tag
    $file = Join-Path $dir $mod.asset
    if (Test-Path $file) { return $file }
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Invoke-Gh release download $mod.tag -R "$($kit.owner)/$($mod.repo)" -p $mod.asset -D $dir
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $file)) {
        $have = Invoke-Gh release view $mod.tag -R "$($kit.owner)/$($mod.repo)" --json assets -q '.assets[].name'
        if ($LASTEXITCODE -ne 0) { Fail "$($mod.repo): there's no published release $($mod.tag) yet" }
        Fail "$($mod.repo) $($mod.tag): no asset '$($mod.asset)'. Release has: $($have -join ', ')"
    }
    return $file
}

# Writes a file from the mod's repo, at its release tag, into $dest.
function Save-RepoFile($mod, [string]$path, [string]$dest) {
    $json = Invoke-Gh api "repos/$($kit.owner)/$($mod.repo)/contents/$($path)?ref=$($mod.tag)"
    if ($LASTEXITCODE -ne 0) { Fail "$($mod.repo) $($mod.tag): couldn't read $path" }
    $content = ($json -join "`n" | ConvertFrom-Json).content
    [System.IO.File]::WriteAllBytes($dest, [Convert]::FromBase64String($content))
}

# Copies the mod's folder out of its release zip. Release zips differ: some
# nest the folder a level deeper, and some use backslashes in entry names, so
# find the folder by its ModInfo.xml rather than assuming a layout.
function Expand-Mod($mod, [string]$zipPath, [string]$dest) {
    $archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $entries = @($archive.Entries | ForEach-Object {
            [pscustomobject]@{ Entry = $_; Path = $_.FullName.Replace('\', '/') }
        })
        $infos = @($entries | Where-Object { $_.Path -match "(^|/)$([regex]::Escape($mod.folder))/ModInfo\.xml$" })
        if ($infos.Count -ne 1) { Fail "$($mod.asset): expected one $($mod.folder)/ModInfo.xml, found $($infos.Count)" }
        $prefix = $infos[0].Path.Substring(0, $infos[0].Path.Length - 'ModInfo.xml'.Length)

        foreach ($e in $entries) {
            if (-not $e.Path.StartsWith($prefix) -or $e.Path.EndsWith('/')) { continue }
            $target = Join-Path $dest ($e.Path.Substring($prefix.Length).Replace('/', '\'))
            New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e.Entry, $target, $true)
        }
    } finally { $archive.Dispose() }
}

Write-Host "==> $($kit.displayName) v$($kit.version)"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Path $stage -Force | Out-Null

$lines = @()
foreach ($mod in $kit.mods) {
    $dest = Join-Path (Join-Path $stage ($mod.group.Replace('/', '\'))) $mod.folder
    Write-Host ("    {0,-30} {1,-8} -> {2}" -f $mod.folder, $mod.version, $mod.group)

    Expand-Mod $mod (Get-Asset $mod) $dest

    [xml]$info = Get-Content (Join-Path $dest 'ModInfo.xml') -Raw
    $found = $info.SelectSingleNode('//Version').GetAttribute('value')
    if ($found -ne $mod.version) { Fail "$($mod.folder): ModInfo.xml says $found, kit.json says $($mod.version)" }

    # The mods' own release zips don't carry their license, so the kit adds it.
    Save-RepoFile $mod 'LICENSE' (Join-Path $dest 'LICENSE')
    Save-RepoFile $mod 'NOTICE.md' (Join-Path $dest 'NOTICE.md')

    $lines += ("  {0,-30} {1,-8} {2}" -f $mod.folder, $mod.version, $mod.group)
}

$readme = (Get-Content (Join-Path $PSScriptRoot 'kit-readme.txt') -Raw).
    Replace('{{VERSION}}', $kit.version).
    Replace('{{MODS}}', ($lines -join "`r`n"))
[System.IO.File]::WriteAllText((Join-Path $stage 'README.txt'), $readme, $utf8)

# Zip by hand: PowerShell 5.1's Compress-Archive writes backslashes into entry
# names, which Linux servers unpack as literal file names.
Write-Host "==> zipping"
if (Test-Path $zip) { Remove-Item $zip -Force }
$out = [System.IO.Compression.ZipFile]::Open($zip, 'Create')
try {
    $root = (Resolve-Path $stage).Path
    Get-ChildItem $stage -Recurse -File | Sort-Object FullName | ForEach-Object {
        $rel = "$name/" + $_.FullName.Substring($root.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($out, $_.FullName, $rel, 'Optimal') | Out-Null
    }
} finally { $out.Dispose() }

$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
Write-Host ""
Write-Host "built:  $zip"
Write-Host "sha256: $hash"
Write-Host "size:   $((Get-Item $zip).Length) bytes"
