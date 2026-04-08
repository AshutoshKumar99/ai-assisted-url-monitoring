<#
AI-Assisted URL Monitoring Script (Public / Generic Version)

Purpose:
- URL-level availability monitoring
- Rule-based RCA for known issues
- AI-assisted RCA for DNS / hostname failures
- Teams alerting (via webhook)
- Daily logging

⚠️ NOTE:
This is a generic template.
All URLs, server names, and tokens are placeholders.
#>

# ================= CONFIG =================

# Monitoring interval (seconds)
$SleepInterval = 1800

# Expected keyword in the web page
$ExpectedKeyword = "Application Console"

# URL path validation regex
$ExpectedPathRegex = "/application/?$"

# Log directory
$LogRoot = "C:\URLMonitoringLogs"

# OpenAI key (must be set as ENV variable)
$OPENAI_API_KEY = $env:OPENAI_API_KEY
if (-not $OPENAI_API_KEY) {
    Write-Host "OPENAI_API_KEY not set in environment." -ForegroundColor Red
    exit
}

# Teams Webhook (REPLACE WITH YOUR OWN)
$TeamsWebhookUrl = "<REPLACE_WITH_TEAMS_WEBHOOK_URL>"

# ================= URL DEFINITIONS =================
# 👉 Replace with your own URLs

$ProductionUrls = @(
    @{ Platform="WINDOWS"; Env="PRODUCTION"; Name="prod-server-01"; URL="https://prod.example.com/application" },
    @{ Platform="WINDOWS"; Env="PRODUCTION"; Name="prod-server-02"; URL="https://prod.example.com/application" }
)

$DevelopmentUrls = @(
    @{ Platform="WINDOWS"; Env="DEVELOPMENT"; Name="dev-server-01"; URL="http://dev.example.com/application" }
)

# ================= URL SUGGESTION HELPER =================
function Suggest-CorrectUrl {
    param($Item)
    try { $u = [uri]$Item.URL } catch { return "N/A" }

    $scheme = ($Item.Env -eq "PRODUCTION") ? "https" : $u.Scheme
    $portPart = $u.IsDefaultPort ? "" : ":$($u.Port)"
    return "$scheme://$($u.Host)$portPart/application/"
}

# ================= AI RCA =================
function Invoke-AIForDnsFailure {
    param($Item)

    Write-Host "AI: DNS / Hostname issue detected for $($Item.Name)" -ForegroundColor Cyan

    # Placeholder AI call logic for public repo
    Write-Host "AI RCA: Possible DNS resolution or hostname configuration issue." -ForegroundColor Magenta
}

# ================= RULE ENGINE =================
function Get-RuleRCA {
    param($Item, $StatusCode)

    if ($Item.Env -eq "PRODUCTION" -and $Item.URL -match "^http://") {
        return @{
            Hit=$true
            RCA="HTTP used in PRODUCTION environment"
            Fix="Use HTTPS for production endpoints"
            Suggest=Suggest-CorrectUrl $Item
        }
    }

    if ($Item.URL -notmatch $ExpectedPathRegex) {
        return @{
            Hit=$true
            RCA="Invalid application path in URL"
            Fix="Correct the application endpoint"
            Suggest=Suggest-CorrectUrl $Item
        }
    }

    if ($StatusCode -eq 404) {
        return @{
            Hit=$true
            RCA="Application endpoint returned 404"
            Fix="Verify deployment and context path"
            Suggest=Suggest-CorrectUrl $Item
        }
    }

    return @{ Hit=$false }
}

# ================= MAIN LOOP =================
while ($true) {

    $Results = @()
    $anyDownDetected = $false

    foreach ($group in @(
        @{ Items=$ProductionUrls },
        @{ Items=$DevelopmentUrls }
    )) {

        foreach ($item in $group.Items) {

            $status="UP"
            $dnsFailure=$false
            $httpStatus=$null

            try {
                $resp = Invoke-WebRequest -Uri $item.URL -TimeoutSec 20 -UseBasicParsing
                $httpStatus = $resp.StatusCode
                if ($resp.Content -notmatch $ExpectedKeyword) {
                    $status="DOWN"
                }
            }
            catch {
                $status="DOWN"
                if ($_.Exception.Message -match "resolve") {
                    $dnsFailure=$true
                    $anyDownDetected=$true
                }
            }

            Write-Host "$($item.Env) | $($item.Name) | $status"

            if ($dnsFailure) {
                Invoke-AIForDnsFailure $item
            }
            elseif ($status -eq "DOWN") {
                $rule = Get-RuleRCA $item $httpStatus
                if ($rule.Hit) {
                    Write-Host "RCA: $($rule.RCA)" -ForegroundColor Yellow
                    Write-Host "Fix: $($rule.Fix)" -ForegroundColor Yellow
                }
            }

            $Results += [pscustomobject]@{
                Environment=$item.Env
                Name=$item.Name
                Status=$status
            }
        }
    }

    if (!(Test-Path $LogRoot)) {
        New-Item -ItemType Directory -Path $LogRoot | Out-Null
    }

    $logFile = Join-Path $LogRoot "monitor_$(Get-Date -Format yyyyMMdd).log"
    $Results | Out-File -Append $logFile

    Start-Sleep $SleepInterval
}
