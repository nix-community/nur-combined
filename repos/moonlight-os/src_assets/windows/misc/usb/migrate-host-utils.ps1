$ErrorActionPreference = 'Stop'

# Retain the prototype's executable and config for rollback. Only disable its
# SYSTEM task so it cannot race Helios for device ownership or port 48020.
foreach ($taskName in @('MlosHostUtils', 'MoonlightOSHostUtils')) {
    $legacy = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($null -ne $legacy) {
        Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        Disable-ScheduledTask -TaskName $taskName | Out-Null
        Write-Host "Disabled legacy task $taskName; its files remain available for rollback."
    }
}
