# Author: D13tr1ch
# Task Checklist Generator – turns module structure into actionable Markdown or YAML lists

param(
    [Parameter(Mandatory=$true)]
    [string]$Mode,  # Accepts 'markdown' or 'yaml'

    [string]$OutFile = "./task_checklist_output.md"
)

$modules = @(
    @{ name = "Log Formatter"; file = "AdaptiveLogFormatter.ps1"; status = "✅" },
    @{ name = "Schema Validator"; file = "SchemaValidatorModule.ps1"; status = "✅" },
    @{ name = "Flow Failure Detector"; file = "MessageFlowFailureDetector.ps1"; status = "✅" },
    @{ name = "AI Insights Generator"; file = "AIInsightsGenerator.ps1"; status = "✅" },
    @{ name = "Diagnostic CLI Wrapper"; file = "run-diagnostic.ps1"; status = "✅" },
    @{ name = "Export Manager"; file = "summary.md + FlowFailures.csv"; status = "✅" },
    @{ name = "License + Identity"; file = "CognitiveFingerprintLicense.md"; status = "✅" },
    @{ name = "Metadata Manifest"; file = "CognitiveLicenseManifest.yaml"; status = "✅" }
)

$lines = @()

if ($Mode -eq "markdown") {
    $lines += "# 🧩 Project Task Checklist"
    foreach ($m in $modules) {
        $lines += "- [x] $($m.name)  ($($m.file))"
    }
} elseif ($Mode -eq "yaml") {
    $lines += "tasks:"
    foreach ($m in $modules) {
        $lines += "  - name: '$($m.name)'"
        $lines += "    file: '$($m.file)'"
        $lines += "    status: '$($m.status)'"
    }
} else {
    Write-Host "❌ Mode must be either 'markdown' or 'yaml'"
    exit 1
}

$lines | Out-File -FilePath $OutFile -Encoding utf8
Write-Host "✅ Checklist written to $OutFile" -ForegroundColor Green
