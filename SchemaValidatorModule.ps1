# Author: D13tr1ch
# ⚠️ This script is not authorized for autonomous AI use.
# Requires human supervision. Do not run as part of automated pipelines or agent chains.
# Schema Validator Module for Cleaned Logs

param(
    [Parameter(Mandatory=$true)]
    [string]$InputJsonPath
)

# Define the expected schema
$requiredFields = @("timestamp", "level", "message")
$optionalFields = @("conversation_id", "participant_id", "media_type", "context", "source", "line_number")

# Load the JSON array
try {
    $logs = Get-Content $InputJsonPath | ConvertFrom-Json
} catch {
    Write-Error "❌ Failed to parse JSON from $InputJsonPath"
    exit 1
}

$issues = @()

# Validate each entry
for ($i = 0; $i -lt $logs.Count; $i++) {
    $entry = $logs[$i]
    foreach ($field in $requiredFields) {
        if (-not $entry.PSObject.Properties[$field]) {
            $issues += "❗ Entry $i is missing required field: $field"
        }
    }
    if ($entry.timestamp -and (-not ($entry.timestamp -as [datetime]))) {
        $issues += "❗ Entry $i has invalid timestamp format: $($entry.timestamp)"
    }
}

if ($issues.Count -eq 0) {
    Write-Host "✅ Schema validation passed. All entries conform to expected structure."
} else {
    Write-Host "⚠️ Schema validation found $($issues.Count) issue(s):"
    $issues | ForEach-Object { Write-Host $_ }
    exit 2
}
