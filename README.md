# 🚀 AI-Assisted URL Monitoring (PowerShell)

## 📌 Overview

This project demonstrates a **hybrid URL monitoring solution** that combines:

* ✅ Deterministic **rule-based validation**
* 🤖 **AI-assisted Root Cause Analysis (RCA)** for deeper insights

The script is designed to run from a **controlled monitoring environment (VDI/server)**, ensuring consistent and reliable results independent of end-user network conditions.

---

## ⚙️ Configuration

The script requires the following environment variables:

* `OPENAI_API_KEY` → API key for AI-assisted RCA
* `TEAMS_WEBHOOK_URL` → Microsoft Teams Incoming Webhook URL

### 🔧 Setup (PowerShell)

```powershell
setx OPENAI_API_KEY "your-api-key"
setx TEAMS_WEBHOOK_URL "your-teams-webhook-url"
```

> ⚠️ Restart your terminal after setting environment variables.

---

## 🏗️ Architecture

The solution follows a structured monitoring workflow:

1. ⏱️ **Scheduled Execution**

   * Runs every 30 minutes (via Task Scheduler / cron equivalent)

2. 🌐 **Primary URL Check**

   * Uses `Invoke-WebRequest` for HTTPS probing

3. 🧠 **Rule Engine (Deterministic Checks)**

   * Detects common issues:

     * HTTP vs HTTPS mismatch
     * Invalid paths (404 errors)

4. 🤖 **AI-Assisted RCA**

   * Triggered only for **DNS / hostname resolution failures**
   * Uses OpenAI to generate human-readable root cause analysis

5. 📢 **Output & Alerting**

   * Console logs
   * Daily log file
   * Microsoft Teams notifications

---

## 🎯 Key Features

* 🔍 **URL-level monitoring** (not just service availability)
* 📄 **Content validation** beyond HTTP status codes
* ⚡ **Selective AI usage** (cost-efficient & meaningful)
* 🌍 **Environment-independent results**
* 🔔 **Real-time alerting via Teams**

---

## 💡 Use Cases

* Monitoring:

  * Admin portals
  * Web consoles
  * Internal tools

* Quickly identifying:

  * Real outages vs misconfigurations
  * DNS issues with AI-backed explanations

* Reducing:

  * False alerts
  * Manual RCA effort

---

## ▶️ How to Run

1. Clone the repository
2. Set environment variables (as shown above)
3. Run the script:

```powershell
.\your-script-name.ps1
```

4. (Optional) Schedule using **Windows Task Scheduler** for automated monitoring

---

## 📊 Sample Workflow
<img width="1016" height="158" alt="image" src="https://github.com/user-attachments/assets/893cef7f-e271-4d88-b9ba-0c271ab98db2" />

URL Check → Rule Engine → 
   ├── Known Issue → Report
   └── Unknown/DNS Issue → AI RCA → Report
```

---

## ⚠️ Disclaimer

This is a **generic public version** of the solution.

* All URLs, hostnames, and integrations are **placeholders**
* No sensitive or production data is included
* AI responses may vary and should be reviewed before critical decisions

---

## 🔮 Future Enhancements

* Email/SNS alert integration
* Dashboard (Grafana / Web UI)
* Multi-region monitoring support
* Config-driven URL management (JSON/YAML)

---

## 👨‍💻 Author

**Ashutosh Kumar**


---
