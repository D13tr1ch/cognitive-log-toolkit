# Author: D13tr1ch
# AI Analysis Layer – Summarizes cleaned logs and flow issues

param(
    [Parameter(Mandatory=$true)]
    [string]$CleanedLogPath,

    [string]$FlowFailurePath = "",
    [string]$OutputFolder = "./exported_report"
)

if (-not (Test-Path $CleanedLogPath)) {
    Write-Error "Cleaned log not found: $CleanedLogPath"
    exit 1
}

$logs = Get-Content $CleanedLogPath | ConvertFrom-Json
$failures = @()
if ($FlowFailurePath -and (Test-Path $FlowFailurePath)) {
    $failures = Get-Content $FlowFailurePath | ConvertFrom-Json
}

# Group by level and count
$levelCounts = $logs | Group-Object level | ForEach-Object {
    [PSCustomObject]@{ Level = $_.Name; Count = $_.Count }
}

# Top message phrases
$topMessages = $logs | Group-Object message | Sort-Object Count -Descending | Select-Object -First 5

# Build markdown report
$md = "# AI Log Insight Summary`n`n"
$md += "**Log entries analyzed:** $($logs.Count)`n"
$md += "**Conversations:** $((($logs | Select-Object -ExpandProperty conversation_id) | Sort-Object -Unique).Count)`n"
$md += "**Flow Failures Detected:** $($failures.Count)`n`n"
$md += "## Error Levels`n"
foreach ($lvl in $levelCounts) {
    $md += "- $($lvl.Level): $($lvl.Count)`n"
}
$md += "`n## Top Messages:`n"
foreach ($msg in $topMessages) {
    $md += "- \"$($msg.Name)\" ($($msg.Count))`n"
}
$md += "`n## Flow Issues:`n"
foreach ($f in $failures) {
    $md += "- [$($f.conversation_id)] $($f.issue)`n"
}

# Save markdown
$insightPath = Join-Path $OutputFolder "LogInsights.md"
$md | Out-File $insightPath

# Save JSON version
$summaryJson = [PSCustomObject]@{
    total_logs = $logs.Count
    error_levels = $levelCounts
    top_messages = $topMessages
    flow_issues = $failures
}
$summaryJson | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $OutputFolder "LogInsights.json")

Write-Host "🤖 Log insights generated: $insightPath" -ForegroundColor Green