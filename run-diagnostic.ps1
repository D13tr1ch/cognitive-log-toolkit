# Author: D13tr1ch
# Unified CLI runner for the AI Log Diagnostic Toolkit

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$LogPath,

    [string]$FormatLibrary = "./LogFormatLibrary.json",
    [string]$OutputPath = "./Cleaned-Logs.json",

    [switch]$RunFormatter,
    [switch]$RunValidator,
    [switch]$RunFlowDetect,
    [switch]$RunAll,
    [switch]$Verbose,

    [string]$SummaryNote = "",
    [string]$OutFolder = "./exported_report",

    [string]$MessageContains,
    [string]$Level,
    [string]$ConversationID,
    [datetime]$Since,
    [datetime]$Until
)

function Show-Section($label) {
    if ($Verbose) {
        Write-Host "`n=== $label ===" -ForegroundColor Cyan
    }
}

if ($RunAll -or $RunFormatter) {
    Show-Section "Running Formatter"
    & ./AdaptiveLogFormatter.ps1 -LogFilePath $LogPath -FormatLibraryPath $FormatLibrary
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Formatter failed." -ForegroundColor Red
        exit 1
    }
}

if ($RunAll -or $RunValidator) {
    Show-Section "Running Schema Validator"
    & ./SchemaValidatorModule.ps1 -InputJsonPath $OutputPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Schema validation failed." -ForegroundColor Red
        exit 1
    }
}

if ($RunAll -or $RunFlowDetect) {
    Show-Section "Running Flow Failure Detector"
    & ./MessageFlowFailureDetector.ps1 -CleanedJsonPath $OutputPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Flow failure detection failed." -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ All selected modules completed successfully." -ForegroundColor Green

# Create output folder
if (-not (Test-Path $OutFolder)) {
    New-Item -Path $OutFolder -ItemType Directory | Out-Null
}

# Export cleaned log with filters
if (Test-Path "Cleaned-Logs.json") {
    $cleaned = Get-Content "Cleaned-Logs.json" | ConvertFrom-Json
    if ($MessageContains) {
        $cleaned = $cleaned | Where-Object { $_.message -like "*${MessageContains}*" }
    }
    if ($Level) {
        $cleaned = $cleaned | Where-Object { $_.level -eq $Level }
    }
    if ($ConversationID) {
        $cleaned = $cleaned | Where-Object { $_.conversation_id -eq $ConversationID }
    }
    if ($Since) {
        $cleaned = $cleaned | Where-Object { ([datetime]$_.timestamp) -ge $Since }
    }
    if ($Until) {
        $cleaned = $cleaned | Where-Object { ([datetime]$_.timestamp) -le $Until }
    }
    $cleaned | ConvertTo-Json -Depth 4 | Out-File "$OutFolder/Cleaned-Logs.json" -Encoding utf8
}

# Export flow failures to CSV
if (Test-Path "FlowFailures.json") {
    try {
        $failures = Get-Content "FlowFailures.json" | ConvertFrom-Json
        $failures | Export-Csv -Path "$OutFolder/FlowFailures.csv" -NoTypeInformation
    } catch {
        Write-Host "⚠️ Failed to export FlowFailures.csv" -ForegroundColor Yellow
    }
}

# Create zip archive of exported folder
$zipPath = "$OutFolder.zip"
Add-Type -Assembly 'System.IO.Compression.FileSystem'
[System.IO.Compression.ZipFile]::CreateFromDirectory($OutFolder, $zipPath)

# Export summary as Markdown
$summaryText = "# Diagnostic Summary Report`n`n**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n**Log Source:** $LogPath`n`n**Reviewer Note:** $SummaryNote`n`nModules Run:`n"
if ($RunAll) { $summaryText += "- All modules executed`n" }
if ($RunFormatter) { $summaryText += "- Formatter`n" }
if ($RunValidator) { $summaryText += "- Schema Validator`n" }
if ($RunFlowDetect) { $summaryText += "- Flow Detector`n" }
$summaryText | Out-File "$OutFolder/summary.md"

Write-Host "📦 Results exported to $OutFolder and bundled as $zipPath" -ForegroundColor Cyan