<#
==========================================================
AI‑ASSISTED URL MONITORING (Public / Generic Version)

🔍 Purpose
- Continuous URL‑level monitoring
- Rule‑based RCA for known issues
- 🤖 AI‑assisted RCA for DNS / hostname failures
- Console output + daily logging

⚠️ NOTE
This is a generic public template.
All URLs, server names, and tokens are placeholders.
OpenAI API key must be provided via environment variable.

AI Model Used: gpt‑4.1‑mini
==========================================================
#>

# ================= GLOBAL CONFIG =================
$SleepInterval      = 1800   # 30 minutes
$ExpectedKeyword    = "Application Console"
$ExpectedPathRegex = "/application/?$"

# ✅ OpenAI API key (ENV variable)
$OPENAI_API_KEY = $env:OPENAI_API_KEY
if (-not $OPENAI_API_KEY) {
    Write-Host "❌ OPENAI_API_KEY is not set in environment." -ForegroundColor Red
    exit
}

# ================= URL SUGGESTION HELPER =================
function Suggest-CorrectUrl {
    param($Item)

    try { $u = [uri]$Item.URL } catch { return "N/A" }

    $scheme   = ($Item.Env -eq "PRODUCTION") ? "https" : $u.Scheme
    $portPart = $u.IsDefaultPort ? "" : ":$($u.Port)"

    return "$scheme://$($u.Host)$portPart/application/"
}

# ================= 🤖 AI HANDLER (REAL CALL) =================
function Invoke-AIForDnsFailure {
    param($Item)

    Write-Host "🤖 AI CALL  : Analyzing DNS / hostname issue..." -ForegroundColor Cyan

    $prompt = @"
A monitoring script detected a DNS or hostname resolution failure.

Environment : $($Item.Env)
Platform    : $($Item.Platform)
Server Name : $($Item.Name)
URL         : $($Item.URL)

Explain the likely root cause in 2 short bullet points
and provide one recommended fix.
Keep the response brief and practical.
"@

    $body = @{
        model = "gpt-4.1-mini"
        messages = @(
            @{ role = "user"; content = $prompt }
        )
        temperature = 0
    } | ConvertTo-Json -Depth 4

    try {
        $response = Invoke-RestMethod `
            -Uri "https://api.openai.com/v1/chat/completions" `
            -Method POST `
            -Headers @{
                "Authorization" = "Bearer $OPENAI_API_KEY"
                "Content-Type"  = "application/json"
            } `
            -Body $body

        Write-Host "🧠 AI RCA   :" -ForegroundColor Magenta
        Write-Host $response.choices[0].message.content -ForegroundColor Magenta
        Write-Host "✨ AI MODEL : gpt‑4.1‑mini" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ AI ERROR : Failed to call OpenAI API" -ForegroundColor Red
    }
}

# ================= RULE ENGINE =================
function Get-RuleRCA {
    param($Item, $HttpStatus)

    if ($Item.Env -eq "PRODUCTION" -and $Item.URL -match "^http://") {
        return @{
            Hit     = $true
            RCA     = "HTTP used in PRODUCTION environment"
            Fix     = "Use HTTPS for production endpoints"
            Suggest = Suggest-CorrectUrl $Item
        }
    }

    if ($Item.URL -notmatch $ExpectedPathRegex) {
        return @{
            Hit     = $true
            RCA     = "Invalid application path in URL"
            Fix     = "Correct the application context path"
            Suggest = Suggest-CorrectUrl $Item
        }
    }

    if ($HttpStatus -eq 404) {
        return @{
            Hit     = $true
            RCA     = "Application endpoint returned 404"
            Fix     = "Verify deployment and application path"
            Suggest = Suggest-CorrectUrl $Item
        }
    }

    return @{ Hit = $false }
}

# ================= URL CONFIG (PLACEHOLDERS) =================
$ProductionUrls = @(
    @{ Platform="WINDOWS"; Env="PRODUCTION"; Name="prod-app-01"; URL="https://prod.example.com/application" },
    @{ Platform="WINDOWS"; Env="PRODUCTION"; Name="prod-app-02"; URL="https://prod.example.com/application" }
)

$DevelopmentUrls = @(
    @{ Platform="WINDOWS"; Env="DEVELOPMENT"; Name="dev-app-01"; URL="http://dev.example.com:8080/application" }
)

# ================= MAIN LOOP =================
while ($true) {

    $Results = @()

    Write-Host "=== URL Monitoring cycle started at $(Get-Date) ===" -ForegroundColor Yellow

    foreach ($group in @(
        @{ Items = $ProductionUrls },
        @{ Items = $DevelopmentUrls }
    )) {

        foreach ($item in $group.Items) {

            $status="UP"
            $httpStatus=$null
            $dnsFailure=$false

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
                }
            }

            Write-Host "$($item.Env) | $($item.Name) | $status"

            # ✅ Always track results
            $Results += [pscustomobject]@{
                Environment = $item.Env
                Name        = $item.Name
                Status      = $status
            }

            if ($dnsFailure) {
                Invoke-AIForDnsFailure $item
                continue
            }

            if ($status -eq "DOWN") {
                $rule = Get-RuleRCA $item $httpStatus
                if ($rule.Hit) {
                    Write-Host "RCA : $($rule.RCA)" -ForegroundColor Yellow
                    Write-Host "Fix : $($rule.Fix)" -ForegroundColor Yellow
                }
            }
        }
    }

    # ================= DAILY LOG FILE =================
    $LogRoot = "C:\URLMonitoringLogs"
    if (!(Test-Path $LogRoot)) {
        New-Item -ItemType Directory -Path $LogRoot | Out-Null
    }

    $logFile = Join-Path $LogRoot "monitor_$(Get-Date -Format yyyyMMdd).log"
    $Results | Out-File -Append $logFile

    Write-Host "Next monitoring cycle in 30 minutes..." -ForegroundColor DarkCyan
    Start-Sleep $SleepInterval
}
