param(
    [Parameter(Mandatory = $true)][string]$ArchivePath,
    [Parameter(Mandatory = $true)][string]$TargetDirectory,
    [Parameter(Mandatory = $true)][string]$CurrentDirectory,
    [Parameter(Mandatory = $true)][ValidatePattern('^[0-9a-fA-F]{64}$')][string]$ExpectedSha256,
    [Parameter(Mandatory = $true)][UInt64]$ExpectedSize,
    [Parameter(Mandatory = $true)][UInt32]$ParentProcessId,
    [Parameter(Mandatory = $true)][UInt16]$HealthPort
)

$ErrorActionPreference = 'Stop'
$ServiceName = 'HeliosService'
$ArchivePath = [System.IO.Path]::GetFullPath($ArchivePath)
$TargetDirectory = [System.IO.Path]::GetFullPath($TargetDirectory)
$CurrentDirectory = [System.IO.Path]::GetFullPath($CurrentDirectory)
$LogPath = Join-Path ([System.IO.Path]::GetDirectoryName($ArchivePath)) 'apply-update.log'
$OldServiceBinary = Join-Path $CurrentDirectory 'tools\heliossvc.exe'
$NewServiceBinary = Join-Path $TargetDirectory 'tools\heliossvc.exe'
$OldProgram = Join-Path $CurrentDirectory 'Helios.exe'
$NewProgram = Join-Path $TargetDirectory 'Helios.exe'
$ServiceChanged = $false
$FirewallChanged = $false

function Write-UpdateLog([string]$Message) {
    $timestamp = [DateTime]::UtcNow.ToString('o')
    Add-Content -LiteralPath $LogPath -Value "$timestamp $Message" -Encoding UTF8
}

function Set-ServiceBinary([string]$BinaryPath) {
    $quotedBinaryPath = '"' + $BinaryPath + '"'
    $result = & sc.exe config $ServiceName 'binPath=' $quotedBinaryPath
    if ($LASTEXITCODE -ne 0) {
        throw "sc.exe could not configure $ServiceName (exit $LASTEXITCODE): $result"
    }
}

function Wait-ForServiceState([string]$State, [int]$Seconds) {
    $deadline = [DateTime]::UtcNow.AddSeconds($Seconds)
    do {
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        if ($service.Status.ToString() -eq $State) {
            return $true
        }
        Start-Sleep -Milliseconds 500
    } while ([DateTime]::UtcNow -lt $deadline)
    return $false
}

function Set-FirewallProgram([string]$FromProgram, [string]$ToProgram) {
    $fromPath = [System.IO.Path]::GetFullPath($FromProgram)
    $filters = Get-NetFirewallApplicationFilter -ErrorAction Stop |
        Where-Object { $_.Program -and ([System.IO.Path]::GetFullPath($_.Program) -eq $fromPath) }
    foreach ($filter in $filters) {
        $filter | Set-NetFirewallApplicationFilter -Program $ToProgram -ErrorAction Stop | Out-Null
        $script:FirewallChanged = $true
    }
    return @($filters).Count
}

function Test-NewHelios([int]$Seconds) {
    $expectedPath = [System.IO.Path]::GetFullPath((Join-Path $TargetDirectory 'Helios.exe'))
    $deadline = [DateTime]::UtcNow.AddSeconds($Seconds)
    do {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        $process = Get-CimInstance Win32_Process -Filter "Name = 'Helios.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.ExecutablePath -and ([System.IO.Path]::GetFullPath($_.ExecutablePath) -eq $expectedPath) } |
            Select-Object -First 1
        $client = $null
        try {
            $client = New-Object System.Net.Sockets.TcpClient
            $connected = $client.ConnectAsync('127.0.0.1', $HealthPort).Wait(1000) -and $client.Connected
        } catch {
            $connected = $false
        } finally {
            if ($null -ne $client) { $client.Dispose() }
        }
        if ($service.Status -eq 'Running' -and $null -ne $process -and $connected) {
            return $true
        }
        Start-Sleep -Seconds 1
    } while ([DateTime]::UtcNow -lt $deadline)
    return $false
}

try {
    Write-UpdateLog "Waiting for Helios process $ParentProcessId to exit."
    $parent = Get-Process -Id $ParentProcessId -ErrorAction SilentlyContinue
    if ($null -ne $parent -and -not $parent.WaitForExit(60000)) {
        throw 'The previous Helios process did not exit within 60 seconds.'
    }

    if (-not (Test-Path -LiteralPath $ArchivePath -PathType Leaf)) {
        throw 'The verified update archive is missing.'
    }
    if ((Get-Item -LiteralPath $ArchivePath).Length -ne $ExpectedSize) {
        throw 'The update archive size changed before installation.'
    }
    $actualHash = (Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash
    if ($actualHash -ne $ExpectedSha256.ToUpperInvariant()) {
        throw 'The update archive hash changed before installation.'
    }
    if (Test-Path -LiteralPath $TargetDirectory) {
        throw 'The target update directory already exists.'
    }
    if (-not (Test-Path -LiteralPath $OldServiceBinary -PathType Leaf)) {
        throw 'The current service wrapper is missing.'
    }

    Write-UpdateLog "Expanding the verified archive to $TargetDirectory."
    Expand-Archive -LiteralPath $ArchivePath -DestinationPath $TargetDirectory
    $requiredFiles = @(
        (Join-Path $TargetDirectory 'Helios.exe'),
        $NewServiceBinary,
        (Join-Path $TargetDirectory 'assets\web\index.html')
    )
    foreach ($requiredFile in $requiredFiles) {
        if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
            throw "The staged update is incomplete: $requiredFile is missing."
        }
    }

    $oldConfig = Join-Path $CurrentDirectory 'config'
    $newConfig = Join-Path $TargetDirectory 'config'
    if (Test-Path -LiteralPath $oldConfig -PathType Container) {
        Copy-Item -LiteralPath $oldConfig -Destination $newConfig -Recurse
    }

    Write-UpdateLog 'Waiting for the existing service to stop.'
    $service = Get-Service -Name $ServiceName -ErrorAction Stop
    if ($service.Status -ne 'Stopped') {
        Stop-Service -Name $ServiceName -Force
    }
    if (-not (Wait-ForServiceState -State 'Stopped' -Seconds 30)) {
        throw 'The existing Helios service did not stop.'
    }

    $updatedFirewallRules = Set-FirewallProgram -FromProgram $OldProgram -ToProgram $NewProgram
    Write-UpdateLog "Updated $updatedFirewallRules firewall application rule(s) for the staged executable."

    Write-UpdateLog "Switching $ServiceName to $NewServiceBinary."
    Set-ServiceBinary $NewServiceBinary
    $ServiceChanged = $true
    Start-Service -Name $ServiceName
    if (-not (Test-NewHelios -Seconds 60)) {
        throw 'The updated Helios service did not become healthy within 60 seconds.'
    }

    Write-UpdateLog 'Update completed successfully. The previous installation was retained for rollback.'
    exit 0
} catch {
    Write-UpdateLog "Update failed: $($_.Exception.Message)"
    if ($ServiceChanged) {
        try {
            Write-UpdateLog "Rolling $ServiceName back to $OldServiceBinary."
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
            Wait-ForServiceState -State 'Stopped' -Seconds 30 | Out-Null
            Set-ServiceBinary $OldServiceBinary
            Start-Service -Name $ServiceName
            if (-not (Wait-ForServiceState -State 'Running' -Seconds 60)) {
                Write-UpdateLog 'Rollback service did not return to Running state.'
            } else {
                Write-UpdateLog 'Rollback completed successfully.'
            }
        } catch {
            Write-UpdateLog "Rollback failed: $($_.Exception.Message)"
        }
    }
    if ($FirewallChanged) {
        try {
            $restoredFirewallRules = Set-FirewallProgram -FromProgram $NewProgram -ToProgram $OldProgram
            Write-UpdateLog "Restored $restoredFirewallRules firewall application rule(s)."
        } catch {
            Write-UpdateLog "Firewall rollback failed: $($_.Exception.Message)"
        }
    }
    exit 1
}
