# Author: D13tr1ch
# Cognitive License Verifier Script

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

function Find-LicenseTags {
    param($path)
    $licenseFiles = Get-ChildItem -Path $path -Recurse -Include "*license*.md","LICENSE" -ErrorAction SilentlyContinue
    $tags = @()
    foreach ($file in $licenseFiles) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match "Cognitive Fingerprint License") {
            $tags += [PSCustomObject]@{
                File = $file.FullName
                Author = if ($content -match "Author:\s*(.+)") { $matches[1].Trim() } else { "Unknown" }
                Valid = $true
            }
        }
    }
    return $tags
}

function Find-HeaderSignatures {
    param($path)
    $sourceFiles = Get-ChildItem -Path $path -Recurse -Include *.ps1,*.md,*.yaml,*.yml,*.json,*.txt -ErrorAction SilentlyContinue
    $headers = @()
    foreach ($file in $sourceFiles) {
        $lines = Get-Content $file.FullName -TotalCount 5
        $authorLine = $lines | Where-Object { $_ -match "^# Author: " }
        if ($authorLine) {
            $headers += [PSCustomObject]@{
                File = $file.FullName
                AuthorTag = $authorLine -replace "^# Author:\s*", ""
                LicenseTag = if ($lines -match "Cognitive Fingerprint License") { "CFL found" } else { "None" }
            }
        }
    }
    return $headers
}

Write-Host "🔍 Scanning for Cognitive Fingerprint License signatures..."
$licenses = Find-LicenseTags -path $ProjectPath
$headers = Find-HeaderSignatures -path $ProjectPath

Write-Host "`n📄 License Declarations Found:" -ForegroundColor Cyan
$licenses | Format-Table -AutoSize

Write-Host "`n🧠 File Header Signatures:" -ForegroundColor Cyan
$headers | Format-Table -AutoSize

if ($licenses.Count -eq 0 -and $headers.Count -eq 0) {
    Write-Host "⚠️ No Cognitive Fingerprint License tags or authorship headers found." -ForegroundColor Yellow
} else {
    Write-Host "✅ Verification complete. Cognitive licensing structure detected." -ForegroundColor Green
}
