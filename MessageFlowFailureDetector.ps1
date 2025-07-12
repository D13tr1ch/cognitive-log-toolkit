# Author: D13tr1ch
# ⚠️ This script is not authorized for autonomous AI use.
# Requires human supervision. Do not run as part of automated pipelines or agent chains.
# Message Flow Failure Detector for Genesys-style Logs

param(
    [Parameter(Mandatory=$true)]
    [string]$CleanedJsonPath
)

# Load logs
try {
    $logs = Get-Content $CleanedJsonPath | ConvertFrom-Json
} catch {
    Write-Error "❌ Failed to parse cleaned JSON logs."
    exit 1
}

# Group logs by conversation ID
$groupedLogs = $logs | Where-Object { $_.conversation_id } | Group-Object -Property conversation_id

$flowFailures = @()

foreach ($group in $groupedLogs) {
    $cid = $group.Name
    $events = $group.Group | Sort-Object timestamp

    $hasStart = $events.message -match "(?i)call initiated"
    $hasConnect = $events.message -match "(?i)(agent connected|participant joined)"
    $hasDrop = $events.message -match "(?i)(call dropped|transfer failed)"
    $hasEnd = $events.message -match "(?i)call ended"

    if ($hasStart -and -not $hasConnect -and $hasDrop) {
        $flowFailures += [PSCustomObject]@{
            conversation_id = $cid
            issue = "Dropped before connection"
            start_time = ($events | Where-Object { $_.message -match "(?i)call initiated" }).timestamp
            drop_time = ($events | Where-Object { $_.message -match "(?i)(call dropped|transfer failed)" })[0].timestamp
        }
    } elseif ($hasStart -and $hasConnect -and -not $hasEnd) {
        $flowFailures += [PSCustomObject]@{
            conversation_id = $cid
            issue = "Missing call end"
            start_time = ($events | Where-Object { $_.message -match "(?i)call initiated" }).timestamp
            connect_time = ($events | Where-Object { $_.message -match "(?i)(agent connected|participant joined)" })[0].timestamp
        }
    }
}

if ($flowFailures.Count -eq 0) {
    Write-Host "✅ No message flow failures detected."
} else {
    Write-Host "⚠️ Detected $($flowFailures.Count) potential message flow failure(s):"
    $flowFailures | Format-Table -AutoSize
    $flowFailures | ConvertTo-Json -Depth 4 | Set-Content -Path "FlowFailures.json"
    Write-Host "📁 Output written to FlowFailures.json"
}
