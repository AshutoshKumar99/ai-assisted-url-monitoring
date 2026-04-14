# 🚀 AI‑Assisted URL Monitoring (PowerShell)
## 📌 Overview

This project demonstrates a **practical, production‑oriented URL monitoring solution** that combines:

*   🧠 **Rule‑based validation** for known and deterministic issues
*   🤖 **AI‑assisted RCA** for DNS / hostname resolution failures
*   📊 **Continuous monitoring with logging** for audit and visibility

The script is designed for **real‑world team usage**, where monitoring is performed regularly, **without over‑automation** or alert noise.

***

## ⚙️ Features

*   ✅ URL‑level availability monitoring
*   ✅ Content validation (not just HTTP status codes)
*   ✅ **Rule Engine** for known issues:
    *   HTTP vs HTTPS misuse
    *   Invalid application context paths
    *   HTTP 404 (endpoint not found)
*   ✅ 🤖 **AI‑assisted RCA for DNS failures** (OpenAI)
*   ✅ Console output for live, human‑driven monitoring
*   ✅ Daily log file creation for tracking and evidence

***

## 🧠 AI Usage (Selective & Practical)

AI is used **only for DNS / hostname resolution failures**, to:

*   Explain the **root cause**
*   Suggest **actionable fixes**

This approach ensures:

*   ⚡ Relevant and meaningful insights
*   💰 Controlled and efficient API usage
*   🎯 Real operational value instead of AI noise

***

## 🏗️ How It Works

*   Script runs every **30 minutes**
*   Checks all configured URLs using `Invoke‑WebRequest`
*   Validates:
    *   Page content
    *   URL structure and protocol
*   Applies **Rule Engine** for known issues
*   Triggers **AI analysis only when a DNS failure is detected**
*   Logs results to a **daily log file**

***

## ⚙️ Configuration

### 🔹 Environment Variable (Required for AI)

```powershell
setx OPENAI_API_KEY "your-api-key"
```

> ⚠️ Restart the terminal after setting the environment variable.

***

## 📂 URL Configuration (Example)

```powershell
$ProductionUrls = @(
    @{ Platform="WINDOWS"; Env="PRODUCTION"; Name="prod-app-01"; URL="https://prod.example.com/application" }
)
```

***

## ▶️ How to Run

```powershell
.\URLMonitor.ps1
```

***

## 📊 Sample Output

ℹ️ Sample output is included to demonstrate:

*   Monitoring flow
*   Rule Engine behavior
*   AI‑assisted RCA for DNS issues

(This output is illustrative and uses placeholder values.)

***

## 📁 Logging

*   Logs are stored at:
        C:\URLMonitoringLogs\
*   Log file format:
        monitor_YYYYMMDD.log

Each log entry captures:

*   Environment
*   Server name
*   Status (UP / DOWN)

***

## 💡 Design Philosophy

This solution is intentionally designed to be:

*   👨‍💻 **Engineer‑assisted** (not fully autonomous)
*   🔍 Focused on **validation, visibility, and explainability**
*   ⚖️ Balanced between **manual monitoring and automation**

***

## 🎯 Use Cases

*   Monitoring admin consoles and internal tools
*   Validating application availability post‑deployment or maintenance
*   Detecting configuration and DNS‑related issues
*   Supporting **shift‑based monitoring teams**

***

## ⚠️ Disclaimer

*   This is a **generic public version**
*   All URLs and server names are placeholders
*   No sensitive or production data is included

***

## 🔥 Key Insight

**Bookmarks confirm access.**  
This script ensures **continuous validation, logging, and RCA support** when issues occur.

***

## 👨‍💻 Author

**Ashutosh Kumar**  
DevOps | Cloud | Automation Enthusiast

***

