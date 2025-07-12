# Author: D13tr1ch
# AI Guard Script – Prevents non-human or automated invocation of sensitive tools

param(
    [string]$TriggerScript = ""
)

function Detect-AIAgentPresence {
    $aiRelatedVars = @(
        "OPENAI_API_KEY", "AZURE_OPENAI_KEY", "LLAMA_PATH", "AI_AUTOPILOT", "AUTO_GPT_MODE",
        "GPT_EXECUTION_CONTEXT", "AUTOGPT_INSTANCE_ID", "AGENTOPS_SESSION", "LLM_LAUNCHER_MODE",
        "CI", "GITHUB_ACTIONS", "GITLAB_CI"
    )
    foreach ($var in $aiRelatedVars) {
        if ($env:$var) {
            Write-Warning "🛑 Potential AI or CI environment detected: $var is set."
            return $true
        }
    }
    return $false
}

function Detect-NonHumanExecution {
    $parent = Get-Process -Id (Get-Process -Id $PID).Parent.Id -ErrorAction SilentlyContinue
    if ($parent.ProcessName -match "(python|node|java|dotnet|powershell|pwsh)" -and $parent.MainWindowTitle -eq "") {
        Write-Warning "🛑 Suspicious parent process detected: $($parent.ProcessName) (headless mode)"
        return $true
    }
    return $false
}

Write-Host "🔐 AI Guard active. Validating execution environment..."

if (Detect-AIAgentPresence -or Detect-NonHumanExecution) {
    Write-Error "❌ Execution blocked. This script must be run by a human operator in a supervised terminal session."
    exit 88
} else {
    Write-Host "✅ No automated or AI-linked environment detected."
    if ($TriggerScript) {
        & $TriggerScript
    }
}