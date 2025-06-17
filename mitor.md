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
