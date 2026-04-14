<#
==========================================================
AI‑Assisted URL Monitoring (Generic / Public Version)

Purpose:
- Continuous URL‑level monitoring
- Rule‑based RCA for known issues
- AI‑assisted RCA for DNS / hostname failures (conceptual)
- Console output and daily logging

NOTE:
This is a generic template.
All URLs, server names, and integrations are placeholders.
Production implementations may add alerting or real AI calls.
==========================================================
#>

# ================= GLOBAL CONFIG =================
$SleepInterval      = 1800
$ExpectedKeyword    = "Application Console"
$ExpectedPathRegex = "/application/?$"

# ================= URL SUGGESTION HELPER =================
function Suggest-CorrectUrl {
    param($Item)

    try { $u = [uri]$Item.URL } catch { return "N/A" }

    $scheme   = ($Item.Env -eq "PRODUCTION") ? "https" : $u.Scheme
    $portPart = $u.IsDefaultPort ? "" : ":$($u.Port)"

    return "$scheme://$($u.Host)$portPart/application/"
}

# ================= AI HANDLER (GENERIC / MOCK) =================
function Invoke-AIForServerNameIssue {
    param($Item)

    Write-Host ("{0,-10} : {1}" -f "AI", "DNS / Hostname issue detected") -ForegroundColor Cyan
    Write-Host ("{0,-10} : {1}" -f "AI RCA",
        "Hostname could not be resolved. This usually indicates a DNS mismatch or incorrect server name.") `
        -ForegroundColor Magenta
    Write-Host ("{0,-10} : {1}" -f "AI NOTE",
        "In production, this step can leverage an AI model for detailed RCA.") `
        -ForegroundColor DarkGray
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

    Write-Host "=== URL Monitoring started at $(Get-Date) ===" -ForegroundColor Yellow

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
                Invoke-AIForServerNameIssue $item
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
