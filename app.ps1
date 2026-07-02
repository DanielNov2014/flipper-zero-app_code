dAdd-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show('Badusb success!','Flipper Zero Badusb')
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# --- Main Window Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "System Dashboard"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false

# --- Silent Notification System (No Popups) ---
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
# Extract the default PowerShell icon so the tray icon works reliably
$notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -id $pid).Path)
$notifyIcon.Visible = $true

# --- Title ---
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "SYSTEM STATUS"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(350, 40)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 150)
$form.Controls.Add($titleLabel)

# --- Battery Display ---
$batteryLabel = New-Object System.Windows.Forms.Label
$batteryLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$batteryLabel.Location = New-Object System.Drawing.Point(25, 80)
$batteryLabel.Size = New-Object System.Drawing.Size(350, 30)
$batteryLabel.Text = "Loading Battery Info..."
$form.Controls.Add($batteryLabel)

# --- Battery Checking Logic ---
function Get-BatteryStatus {
    # Silently continue in case this is run on a desktop with no battery
    $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        $statusText = switch ($battery.BatteryStatus) {
            1 { "Discharging" }
            2 { "Plugged In" }
            3 { "Fully Charged" }
            6 { "Charging" }
            7 { "Charging (High)" }
            8 { "Charging (Low)" }
            9 { "Charging (Critical)" }
            default { "Unknown" }
        }
        return "$($battery.EstimatedChargeRemaining)% [$statusText]"
    } else {
        return "No Battery Detected"
    }
}

# --- Live Update Timer (Updates every 5 seconds) ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 5000
$timer.Add_Tick({
    $batteryLabel.Text = "Battery: " + (Get-BatteryStatus)
})
$timer.Start()

# Force a first check immediately
$batteryLabel.Text = "Battery: " + (Get-BatteryStatus)

# --- Test Notification Button ---
$notifBtn = New-Object System.Windows.Forms.Button
$notifBtn.Text = "SEND TEST NOTIFICATION"
$notifBtn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$notifBtn.Location = New-Object System.Drawing.Point(50, 150)
$notifBtn.Size = New-Object System.Drawing.Size(280, 50)
$notifBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
$notifBtn.ForeColor = [System.Drawing.Color]::White
$notifBtn.FlatStyle = 'Flat'

$notifBtn.Add_Click({
    $notifyIcon.BalloonTipTitle = "Dashboard Alert"
    $notifyIcon.BalloonTipText = "This is a native Windows toast notification. No intrusive popups!"
    $notifyIcon.ShowBalloonTip(3000)
})
$form.Controls.Add($notifBtn)

# --- On Load Event ---
$form.Add_Load({
    $notifyIcon.BalloonTipTitle = "Dashboard Loaded"
    $notifyIcon.BalloonTipText = "Your control center is now active in the background."
    $notifyIcon.ShowBalloonTip(3000)
})

# --- Cleanup on Close ---
$form.Add_FormClosed({
    $notifyIcon.Visible = $false
    $notifyIcon.Dispose()
})

# --- Render the GUI ---
$form.ShowDialog() | Out-Null
