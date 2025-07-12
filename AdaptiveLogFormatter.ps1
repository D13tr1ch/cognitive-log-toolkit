# Author: D13tr1ch
# ⚠️ This script is not authorized for autonomous AI use.
# Requires human supervision. Do not run as part of automated pipelines or agent chains.
# Adaptive Log Ingestion + Formatter (PowerShell)

param(
    [Parameter(Mandatory=$true)]
    [string]$LogFilePath,

    [Parameter(Mandatory=$true)]
    [string]$FormatLibraryPath = "./LogFormatLibrary.json"
)

function Get-FormatProfile($sampleLines, $formatLibrary) {
    foreach ($format in $formatLibrary) {
        $matches = 0
        foreach ($pattern in $format.match.contains) {
            if ($sampleLines -match $pattern) {
                $matches++
            }
        }
        if ($matches -ge ($format.match.contains.Count * 0.6)) {
            return $format
        }
    }
    return $null
}

function Normalize-Timestamp($timestamp) {
    try {
        return [datetime]::Parse($timestamp).ToString("o")
    } catch {
        return $timestamp
    }
}

function Redact-SensitiveFields($text) {
    $text = $text -replace '\b(?:\d{1,3}\.){3}\d{1,3}\b', '[REDACTED_IP]'
    $text = $text -replace '[\w.-]+@[\w.-]+', '[REDACTED_EMAIL]'
    $text = $text -replace '(?i)token=\w+', 'token=[REDACTED]'
    return $text
}

# Load format library
$formatLibrary = Get-Content $FormatLibraryPath | ConvertFrom-Json

# Read sample lines
$sampleLines = Get-Content $LogFilePath -First 10 -Raw
$lines = Get-Content $LogFilePath

# Match profile
$matchedFormat = Get-FormatProfile -sampleLines $sampleLines -formatLibrary $formatLibrary

$output = @()

if (-not $matchedFormat) {
    Write-Host "⚠️ No matching format found. Defaulting to line-by-line wrap."
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $output += [PSCustomObject]@{
            timestamp = (Get-Date).ToString("o")
            level = "INFO"
            message = Redact-SensitiveFields $lines[$i]
            source = "unknown"
            line_number = $i + 1
        }
    }
}
elseif ($matchedFormat.match.format -eq "json") {
    foreach ($line in $lines) {
        try {
            $json = $line | ConvertFrom-Json
            $output += [PSCustomObject]@{
                timestamp = Normalize-Timestamp $json.($matchedFormat.fields.timestamp)
                level     = $json.($matchedFormat.fields.level)
                message   = Redact-SensitiveFields $json.($matchedFormat.fields.message)
                source    = $matchedFormat.name
                line_number = $null
            }
        } catch {
            Write-Warning "Failed to parse line as JSON. Skipping."
        }
    }
}
elseif ($matchedFormat.match.format -eq "delimited") {
    $delimiter = $matchedFormat.delimiter
    $useHeader = $matchedFormat.header_row -ne $false
    $headers = @()
    $startIndex = 0

    if ($useHeader) {
        $headers = $lines[0] -split $delimiter
        $startIndex = 1
    } else {
        $firstLineFields = $lines[0] -split $delimiter
        $headers = @(0..($firstLineFields.Count - 1))
    }

    for ($i = $startIndex; $i -lt $lines.Count; $i++) {
        $parsed = @{}
        $values = $lines[$i] -split $delimiter
        for ($j = 0; $j -lt $headers.Count; $j++) {
            $key = $useHeader ? $headers[$j] : "$j"
            $parsed[$key] = $values[$j]
        }
        $output += [PSCustomObject]@{
            timestamp = Normalize-Timestamp $parsed.($matchedFormat.fields.timestamp)
            level     = $parsed.($matchedFormat.fields.level)
            message   = Redact-SensitiveFields $parsed.($matchedFormat.fields.message)
            source    = $matchedFormat.name
            line_number = $i + 1
        }
    }
}
elseif ($matchedFormat.match.format -eq "regex") {
    foreach ($line in $lines) {
        if ($line -match $matchedFormat.regex) {
            $output += [PSCustomObject]@{
                timestamp = Normalize-Timestamp $matches["timestamp"]
                level     = $matches["level"]
                message   = Redact-SensitiveFields $matches["message"]
                source    = $matchedFormat.name
                line_number = $null
            }
        }
    }
}
else {
    Write-Host "📦 Format matched: $($matchedFormat.name). Parsing logic incomplete or unrecognized."
    exit
}

# Output
$output | ConvertTo-Json -Depth 5 | Set-Content -Path "Cleaned-Logs.json"
Write-Host "✅ Cleaned logs saved to Cleaned-Logs.json"
