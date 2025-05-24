param (
    [ValidateSet("start", "stop")]
    [string]$Action,

    [string]$ServiceAccount
)

# Prompt user if parameters were not passed
if (-not $Action) {
    $Action = Read-Host "Enter action (start/stop)"
}
if (-not $ServiceAccount) {
    $ServiceAccount = Read-Host "Enter the service account (e.g. DOMAIN\\svc_account)"
}

# Normalize
$normalizedAccount = $ServiceAccount.ToLower()
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "ServiceControlLog_$timestamp.txt"

# Get services by logon account
$services = Get-WmiObject Win32_Service | Where-Object {
    $_.StartName.ToLower() -eq $normalizedAccount
}

if ($services.Count -eq 0) {
    Write-Host "`n❌ No services found for account: $ServiceAccount" -ForegroundColor Red
    exit
}

Write-Host "`n🔍 Found $($services.Count) service(s) running under: $ServiceAccount" -ForegroundColor Cyan
$services | Select-Object Name, DisplayName, State | Format-Table -AutoSize

# Confirm action
$confirmation = Read-Host "`nAre you sure you want to '$Action' these services? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "❌ Operation cancelled by user." -ForegroundColor Yellow
    exit
}

# Process services
foreach ($service in $services) {
    $svcName = $service.Name
    $svcDisplay = $service.DisplayName
    try {
        if ($Action -eq "stop" -and $service.State -eq "Running") {
            Write-Host "🛑 Stopping: $svcDisplay"
            Stop-Service -Name $svcName -Force
            Add-Content -Path $logFile -Value "Stopped: $svcName ($svcDisplay)"
        }
        elseif ($Action -eq "start" -and $service.State -ne "Running") {
            Write-Host "▶️ Starting: $svcDisplay"
            Start-Service -Name $svcName
            Add-Content -Path $logFile -Value "Started: $svcName ($svcDisplay)"
        }
        else {
            Write-Host "✅ $svcDisplay is already in desired state: $($service.State)" -ForegroundColor Gray
            Add-Content -Path $logFile -Value "Skipped (already $($service.State)): $svcName ($svcDisplay)"
        }
    }
    catch {
        Write-Warning "⚠️ Failed to $Action $svcDisplay. Error: $_"
        Add-Content -Path $logFile -Value "Failed to $Action: $svcName ($svcDisplay) | Error: $_"
    }
}

Write-Host "`n📄 Log saved to: $logFile" -ForegroundColor Green
-------------------------------------------------------------------------------------



▶️ How to Run It
Save as FriendlyServiceControl.ps1 and execute:

powershell
Copy
Edit
.\FriendlyServiceControl.ps1
You’ll be prompted interactively if you don’t provide parameters.

✍️ Example Output
sql
Copy
Edit
Enter action (start/stop): stop
Enter the service account (e.g. DOMAIN\svc_account): DOMAIN\my_service

🔍 Found 3 service(s) running under: DOMAIN\my_service
Name      DisplayName       State
----      -----------       -----
MySvc1    My Service 1      Running
MySvc2    My Service 2      Running
MySvc3    My Service 3      Stopped

Are you sure you want to 'stop' these services? (y/n): y
🛑 Stopping: My Service 1
🛑 Stopping: My Service 2
✅ My Service 3 is already in desired state: Stopped

📄 Log saved to: ServiceControlLog_2025-05-24_12-30-00.txt
Would you like this packaged into a clickable .exe or GUI using Windows Forms or WPF next?








