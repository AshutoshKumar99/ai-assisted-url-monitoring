# AI-Assisted URL Monitoring (PowerShell)

## Overview
This project demonstrates a **hybrid URL monitoring approach** that combines
deterministic rule‑based analysis with **AI-assisted RCA** for DNS/hostname failures.

The script is designed to run from a **controlled monitoring environment (VDI/server)**,
making results independent of end‑user networks or Wi‑Fi conditions.

---

## Architecture
- Scheduled execution (30‑minute interval)
- Primary HTTPS URL probe (`Invoke-WebRequest`)
- Rule Engine for known issues:
  - HTTP vs HTTPS misuse
  - Invalid paths (404)
- AI‑assisted RCA (OpenAI) for DNS resolution failures
- Console output + daily log file

---

## Key Design Decisions
- **URL-level monitoring**, not service-level
- **Content validation**, not just HTTP 200
- AI used **selectively**, not by default
- No dependency on end‑user network conditions

---

## Use Cases
- Monitoring application consoles / admin portals
- Detecting real outages vs configuration mistakes
- Reducing alert noise with explainable RCA

---

## Disclaimer
This is a **generic public version**.
All URLs, hostnames, and integrations are placeholders.
``
