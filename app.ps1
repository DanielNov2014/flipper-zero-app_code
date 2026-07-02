Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show('Badusb success!','Flipper Zero Badusb')
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# --- Main Window Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Daniel's Deployment Dashboard"
$form.Size = New-Object System.Drawing.Size(400, 480)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false

# --- Title ---
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "SYSTEM SETUP"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(350, 50)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 150)
$form.Controls.Add($titleLabel)

# --- App List (Winget IDs) ---
$apps = @(
    @{ Name = "qFlipper"; Id = "FlipperDevicesInc.qFlipper" },
    @{ Name = "Roblox Player"; Id = "Roblox.Roblox" },
    @{ Name = "Discord"; Id = "Discord.Discord" },
    @{ Name = "Python 3"; Id = "Python.Python.3" },
    @{ Name = "Steam"; Id = "Valve.Steam" }
)

$checkBoxes = @()
$yOffset = 80

# --- Generate Checkboxes Dynamically ---
foreach ($app in $apps) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $app.Name
    $cb.Tag = $app.Id
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $cb.Location = New-Object System.Drawing.Point(40, $yOffset)
    $cb.Size = New-Object System.Drawing.Size(300, 30)
    $cb.Checked = $false
    $form.Controls.Add($cb)
    $checkBoxes += $cb
    $yOffset += 40
}

# --- Install Button ---
$installBtn = New-Object System.Windows.Forms.Button
$installBtn.Text = "INSTALL SELECTED"
$installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$installBtn.Location = New-Object System.Drawing.Point(40, $yOffset + 20)
$installBtn.Size = New-Object System.Drawing.Size(300, 50)
$installBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
$installBtn.ForeColor = [System.Drawing.Color]::White
$installBtn.FlatStyle = 'Flat'

# --- Button Logic ---
$installBtn.Add_Click({
    $installBtn.Text = "INSTALLING..."
    $installBtn.Enabled = $false
    $form.Refresh()

    foreach ($cb in $checkBoxes) {
        if ($cb.Checked) {
            $id = $cb.Tag
            # Winget executes silently in the background
            Start-Process -FilePath "winget" -ArgumentList "install -e --id $id --silent --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow
            
            # Turn the text green when that specific app finishes installing
            $cb.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 150)
            $form.Refresh()
        }
    }

    $installBtn.Text = "DONE"
    $installBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 200, 100)
    [System.Windows.Forms.MessageBox]::Show("All selected applications have been installed.", "Setup Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    $form.Close()
})

$form.Controls.Add($installBtn)

# --- Render the GUI ---
$form.ShowDialog() | Out-Null
