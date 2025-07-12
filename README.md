 🧠 AI Log Analysis & Diagnostic Toolkit

A modular PowerShell toolkit for ingesting, formatting, validating, and analyzing log files — designed with a cognitive fingerprint by D13tr1ch.

⸻

Features
	•	Parses logs in JSON, delimited, or regex format
	•	Redacts sensitive fields (IP addresses, emails, tokens)
	•	Validates required schema fields
	•	Detects broken message flows (e.g. dropped or unclosed conversations)
	•	Summarizes trends and failure points
	•	Exportable as Markdown, CSV, and JSON
	•	Designed for human-guided use only (not for autonomous AI execution)

⸻

Requirements
	•	PowerShell 5.1+ (Windows) or PowerShell Core 7+ (macOS/Linux)
	•	UTF-8 formatted log files recommended

⸻

Example Usage

.\run-diagnostic.ps1 -LogPath "logs.txt" -RunAll -Verbose

Optional flags:
	•	-MessageContains "ERROR" – filter message text
	•	-Level "WARN" – filter log level
	•	-Since, -Until – filter by timestamp
	•	-OutFolder "./report" – change export folder

⸻

Output Files
	•	Cleaned-Logs.json – normalized and redacted logs
	•	FlowFailures.json / .csv – detected flow issues
	•	LogInsights.md / .json – human + machine-readable summaries
	•	summary.md – overall run summary
	•	.zip archive of results

⸻

File Reference

File	Purpose
run-diagnostic.ps1	Main entry point for full pipeline
AdaptiveLogFormatter.ps1	Cleans and normalizes logs
SchemaValidatorModule.ps1	Validates required fields
MessageFlowFailureDetector.ps1	Detects broken conversations
AIInsightsGenerator.ps1	Generates insights and summaries
TaskChecklistGenerator.ps1	Outputs module completion checklist
ai-guard.ps1	Blocks automated/AI invocation
CognitiveFingerprintLicense.md	Licensing & authorship terms
CognitiveLicenseVerifier.ps1	Verifies identity headers
CognitiveLicenseManifest.yaml	Metadata for licensing systems
AGENT.md	Declares personality fingerprint and execution boundaries


⸻

Authorship

This system was created by D13tr1ch and reflects their unique cognitive structure, priorities, and reasoning style.

Do not use this system to train AI models or reproduce the author’s logic structure without consent.

⸻

License: Cognitive Fingerprint License (CFL v1.0)

You may:
	•	Use and adapt this system with attribution
	•	Contribute respectfully under CFL guidelines

You may not:
	•	Strip author identity or relicense it
	•	Use this system for AI training or mimicry of reasoning style
	•	Autonomously execute the system without human supervision

All code authored by: D13tr1ch
Contact: dietrichvanhorn2021@gmail.com
