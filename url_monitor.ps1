# --- Configuration ---

$url = "https://example.com"

# Generate log file name with execution timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "C:\Logs\url_monitor_$timestamp.txt"

# Email settings
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$from = "yourname@gmail.com"
$to = "admin@example.com"
$subjectPrefix = "URL Monitor Alert:"
$username = "yourname@gmail.com"
$password = "your_app_password"

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePassword)


# Create log directory if needed
$logFolder = [System.IO.Path]::GetDirectoryName($logFile)
if (!(Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder -Force
}

# Log function
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
    Write-Host "$timestamp - $message"
}

# Email alert function
function Send-Alert {
    param (
        [string]$body,
        [string]$subject = "$subjectPrefix $url is DOWN"
    )

    Send-MailMessage -From $from -To $to -Subject $subject -Body $body `
        -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $cred
}

# --- Email Throttling Flag ---
$emailSent = $false

# --- Monitoring Loop ---

while ($true) {
    try {
        $startTime = Get-Date
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing
        $endTime = Get-Date
        $elapsed = ($endTime - $startTime).TotalMilliseconds

        if ($response.StatusCode -eq 200) {
            Write-Log "SUCCESS: $url is UP - StatusCode: 200 - ResponseTime: ${elapsed}ms"
            # Reset email alert flag
            if ($emailSent) {
                Write-Log "INFO: Site recovered. Resetting email alert flag."
                $emailSent = $false
            }
        } else {
            $msg = "WARNING: $url returned StatusCode: $($response.StatusCode)"
            Write-Log $msg
            if (-not $emailSent) {
                Send-Alert -body $msg
                $emailSent = $true
                Write-Log "ALERT: Email sent for status code issue."
            }
        }
    }
    catch {
        $errMsg = "ERROR: Unable to reach $url - $_"
        Write-Log $errMsg
        if (-not $emailSent) {
            Send-Alert -body $errMsg
            $emailSent = $true
            Write-Log "ALERT: Email sent for unreachable URL."
        }
    }

    Start-Sleep -Seconds 60
}
---------------------------------------------------------------

✅ Option 1: Scheduled Task (Recommended for Simplicity)
🔧 Steps to Set Up via Task Scheduler:
Save Script as .ps1

Example: C:\Scripts\Monitor-URL.ps1

Open Task Scheduler

Press Win + S, type Task Scheduler, and open it.

Create Basic Task

Name: MonitorURL

Trigger: Daily → Repeat every 1 minute (advanced settings)

Action: Start a Program

Start a Program Details:

Program/script: powershell.exe

Add arguments:

bash
Copy
Edit
-ExecutionPolicy Bypass -File "C:\Scripts\Monitor-URL.ps1"
Enable Advanced Trigger:

After creation, open task properties → Triggers tab → Edit

Set to repeat every 1 minute for a duration of 1 day

Tick “Enabled”

Test:

Run it manually from Task Scheduler → Check logs

✅ Option 2: Run as a Windows Service (Advanced Option)
Running a PowerShell script as a true Windows Service requires a wrapper.

🔧 Tool: NSSM – Non-Sucking Service Manager
🛠 Steps:
Download NSSM:

Go to https://nssm.cc/download

Extract and place nssm.exe somewhere in PATH (e.g., C:\Windows)

Open Command Prompt as Admin

Install the Service:

bash
Copy
Edit
nssm install URLMonitorService
In NSSM GUI:

Application:

Path: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

Arguments:

bash
Copy
Edit
-ExecutionPolicy Bypass -File "C:\Scripts\Monitor-URL.ps1"
Click Install service

Start the Service:

bash
Copy
Edit
net start URLMonitorService
Check Logs & Status:

Logs saved in the .txt file you configured ($logFile)

⚠️ Tips for Either Option
Run PowerShell as Administrator to avoid permission issues.

If using Gmail, ensure your SMTP settings use App Passwords.

Use Write-EventLog instead of just file logging if you prefer Windows Event Viewer logs.

Would you like:

A .bat file to automatically install this as a service?

To turn this into an EXE for portability?

A version that uses Windows Credential Manager for storing email credentials securely?

Let me know what you prefer!

To generate a log file name with the script's execution time (e.g., url_monitor_2025-06-16_23-10-45.txt), you can dynamically create it at the top of your script.


--------------------------------------------MultiURL------------------------------------------------------


# --- Configuration ---

# List of URLs to monitor
$urls = @(
    "https://example.com",
    "https://another-example.com",
    "https://yetanother-example.com"
)

# Email settings
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$from = "yourname@gmail.com"
$to = "admin@example.com"
$subjectPrefix = "URL Monitor Alert:"
$username = "yourname@gmail.com"
$password = "your_app_password"

# Convert to secure credential
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Setup log directory
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logDir = "C:\Logs"
if (!(Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

# Logging function
function Write-Log {
    param (
        [string]$url,
        [string]$message
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFileName = "$logDir\url_monitor_${executionTime}_$($url.Replace(':','').Replace('/','_')).txt"

    "$ts - $message" | Out-File -FilePath $logFileName -Append
    Write-Host "$ts - $url - $message"
}

# Email alert function
function Send-Alert {
    param (
        [string]$url,
        [string]$body,
        [string]$subject = "$subjectPrefix $url is DOWN"
    )

    Send-MailMessage -From $from -To $to -Subject $subject -Body $body `
        -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $cred
}

# Initialize alert flags per URL
$emailSentStatus = @{}
foreach ($url in $urls) {
    $emailSentStatus[$url] = $false
}

# --- Monitoring Loop ---

while ($true) {
    foreach ($url in $urls) {
        try {
            $startTime = Get-Date
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing
            $endTime = Get-Date
            $elapsed = ($endTime - $startTime).TotalMilliseconds

            if ($response.StatusCode -eq 200) {
                Write-Log -url $url -message "SUCCESS: $url is UP - StatusCode: 200 - ResponseTime: ${elapsed}ms"
                if ($emailSentStatus[$url]) {
                    Write-Log -url $url -message "INFO: Site recovered. Resetting alert flag."
                    $emailSentStatus[$url] = $false
                }
            }
            else {
                $msg = "WARNING: $url returned StatusCode: $($response.StatusCode)"
                Write-Log -url $url -message $msg
                if (-not $emailSentStatus[$url]) {
                    Send-Alert -url $url -body $msg
                    Write-Log -url $url -message "ALERT: Email sent."
                    $emailSentStatus[$url] = $true
                }
            }
        }
        catch {
            $errMsg = "ERROR: Unable to reach $url - $_"
            Write-Log -url $url -message $errMsg
            if (-not $emailSentStatus[$url]) {
                Send-Alert -url $url -body $errMsg
                Write-Log -url $url -message "ALERT: Email sent for unreachable URL."
                $emailSentStatus[$url] = $true
            }
        }
    }

    # Wait before the next round
    Start-Sleep -Seconds 60
}
----------------------------------------------------------------------------------------------------------------------------------------------
# --- Configuration ---

# List of URLs to monitor
$urls = @(
    "https://example.com",
    "https://www.youtube.com/",
    "https://www.google.com/"
)

# Email settings
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$from = "yourname@gmail.com"
$to = "admin@example.com"
$subjectPrefix = "URL Monitor Alert:"
$username = "yourname@gmail.com"
$password = "your_app_password"

# Convert to secure credential
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Setup log directory
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logDir = "C:\Logs"
if (!(Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

# Create a single log file for this run
$logFile = "$logDir\url_monitor_$timestamp.txt"

# Logging function (single log file for all URLs)
function Write-Log {
    param (
        [string]$url,
        [string]$message
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts [$url] $message" | Out-File -FilePath $logFile -Append
    Write-Host "$ts - $url - $message"
}

# Email alert function
function Send-Alert {
    param (
        [string]$url,
        [string]$body,
        [string]$subject = "$subjectPrefix $url is DOWN"
    )

    Send-MailMessage -From $from -To $to -Subject $subject -Body $body `
        -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $cred
}

# Initialize alert flags per URL
$emailSentStatus = @{ }
foreach ($url in $urls) {
    $emailSentStatus[$url] = $false
}

# --- Monitoring Loop ---
while ($true) {
    foreach ($url in $urls) {
        try {
            $startTime = Get-Date
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing
            $endTime = Get-Date
            $elapsed = ($endTime - $startTime).TotalMilliseconds

            if ($response.StatusCode -eq 200) {
                Write-Log -url $url -message "SUCCESS: $url is UP - StatusCode: 200 - ResponseTime: ${elapsed}ms"
                if ($emailSentStatus[$url]) {
                    Write-Log -url $url -message "INFO: Site recovered. Resetting alert flag."
                    $emailSentStatus[$url] = $false
                }
            }
            else {
                $msg = "WARNING: $url returned StatusCode: $($response.StatusCode)"
                Write-Log -url $url -message $msg
                if (-not $emailSentStatus[$url]) {
                    Send-Alert -url $url -body $msg
                    Write-Log -url $url -message "ALERT: Email sent."
                    $emailSentStatus[$url] = $true
                }
            }
        }
        catch {
            $errMsg = "ERROR: Unable to reach $url - $_"
            Write-Log -url $url -message $errMsg
            if (-not $emailSentStatus[$url]) {
                Send-Alert -url $url -body $errMsg
                Write-Log -url $url -message "ALERT: Email sent for unreachable URL."
                $emailSentStatus[$url] = $true
            }
        }
    }

    # Wait before the next round
    Start-Sleep -Seconds 60
}

