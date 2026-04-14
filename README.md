🚀 AI-Assisted URL Monitoring (PowerShell)
📌 Overview

This project demonstrates a practical URL monitoring solution that combines:

🧠 Rule-based validation for known issues
🤖 AI-assisted RCA for DNS / hostname failures
📊 Continuous monitoring with logging

The script is designed for real-world team usage, where monitoring is performed regularly, but without over-automation.

⚙️ Features
✅ URL-level availability monitoring
✅ Content validation (not just HTTP response)
✅ Rule Engine for:
HTTP vs HTTPS misuse
Invalid application path
404 errors
✅ AI-assisted RCA for DNS failures (using OpenAI)
✅ Console output for live monitoring
✅ Daily log file for tracking & evidence

🧠 AI Usage (Selective & Practical)

AI is used only for DNS / hostname resolution failures, to:
Explain the root cause
Suggest actionable fixes

This ensures:
⚡ Relevant insights
💰 Controlled API usage
🎯 Real value addition

🏗️ How It Works
Script runs every 30 minutes
Checks all configured URLs using Invoke-WebRequest
Validates:
Page content
URL structure
Applies Rule Engine for known issues
Uses AI (only if DNS failure detected)
Logs results to a daily file

⚙️ Configuration
🔹 Environment Variable (Required for AI)
setx OPENAI_API_KEY "your-api-key"

⚠️ Restart terminal after setting the variable.

📂 URL Configuration (Example)
$ProductionUrls = @(
    @{ Platform="WINDOWS"; Env="PRODUCTION"; Name="prod-app-01"; URL="https://prod.example.com/application" }
)
▶️ How to Run
.\URLMonitor.ps1
📊 Sample Output

ℹ️ The sample output is for illustration purposes to demonstrate monitoring flow, rule engine behavior, and AI-assisted RCA.

📁 Logging
Logs are stored in:
C:\URLMonitoringLogs\
File format:
monitor_YYYYMMDD.log
Captures:
Environment
Server name
Status (UP/DOWN)

💡 Design Philosophy
This solution is intentionally designed to be:

👨‍💻 Engineer-assisted (not fully automated)
🔍 Focused on validation & visibility
⚖️ Balanced between manual monitoring and automation

🎯 Use Cases
Monitoring admin consoles / internal tools
Validating application availability
Detecting configuration issues
Supporting shift-based monitoring teams

⚠️ Disclaimer
This is a generic public version
All URLs and server names are placeholders
No sensitive or production data is included

🔥 Key Insight
Bookmarks confirm access.
This script ensures continuous validation, logging, and RCA support when issues occur.

👨‍💻 Author
Ashutosh Kumar
DevOps | Cloud | Automation Enthusiast
