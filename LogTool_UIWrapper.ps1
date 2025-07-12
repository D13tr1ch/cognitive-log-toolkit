# Author: D13tr1ch
# Log Tool WinForms UI Wrapper (PowerShell)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "AI Log Tool"
$form.Size = New-Object System.Drawing.Size(720, 540)
$form.StartPosition = "CenterScreen"

# File Picker Label
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(120,20)
$label.Text = "Select Log File:"
$form.Controls.Add($label)

# File Path Textbox
$logPathBox = New-Object System.Windows.Forms.TextBox
$logPathBox.Location = New-Object System.Drawing.Point(130, 18)
$logPathBox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($logPathBox)

# Browse Button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(600, 16)
$browseButton.Size = New-Object System.Drawing.Size(75, 24)
$browseButton.Text = "Browse"
$browseButton.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "Log Files (*.log;*.txt;*.json)|*.log;*.txt;*.json|All files (*.*)|*.*"
    if ($fileDialog.ShowDialog() -eq "OK") {
        $logPathBox.Text = $fileDialog.FileName
    }
})
$form.Controls.Add($browseButton)

# Run Button
$runButton = New-Object System.Windows.Forms.Button
$runButton.Location = New-Object System.Drawing.Point(280, 60)
$runButton.Size = New-Object System.Drawing.Size(120, 30)
$runButton.Text = "Run Pipeline"
$runButton.Add_Click({
    $logPath = $logPathBox.Text
    if (-not (Test-Path $logPath)) {
        [System.Windows.Forms.MessageBox]::Show("Invalid log file path.", "Error")
        return
    }

    $output = & ./run-diagnostic.ps1 -LogPath $logPath -RunAll -Verbose

    # Load cleaned logs and extract field list
    try {
        $cleaned = Get-Content "Cleaned-Logs.json" | ConvertFrom-Json
        $fields = @{}
        foreach ($entry in $cleaned[0..[math]::Min(10, $cleaned.Count-1)]) {
            foreach ($prop in $entry.PSObject.Properties) {
                if (-not $fields.ContainsKey($prop.Name)) {
                    $fields[$prop.Name] = $prop.Value
                }
            }
        }

        $filtersText = "[Filterable Fields Detected:]`n"
        foreach ($k in $fields.Keys) {
            $filtersText += "- $k: $($fields[$k].GetType().Name)`n"
        }
        $outputBox.Text = "[Pipeline Complete]`n$output`n`n$filtersText"
    } catch {
        $outputBox.Text = "Pipeline ran, but failed to extract cleaned log fields."
    }
})
$form.Controls.Add($runButton)

# Output Textbox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(10, 110)
$outputBox.Size = New-Object System.Drawing.Size(660, 370)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$form.Controls.Add($outputBox)

# Show the form
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()