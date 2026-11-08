# Aliases
Set-Alias touch New-Item
Set-Alias g git
Set-Alias gg gitui
Set-Alias vim nvim
Set-Alias codi codium
Set-Alias exp explorer

# Starship
$env:STARSHIP_CONFIG = "C:\Configs\starship\starship.toml"
Invoke-Expression (&starship init powershell)

# Oh My Posh
# oh-my-posh init pwsh --config C:\code\config\PowerShell\ahmetcetinkaya.omp.json | Invoke-Expression
# oh-my-posh disable notice # Disable available update notice
# Posh Git
# $env:POSH_GIT_ENABLED = $true
# Import-Module posh-git

# PSReadLine 
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellStyle None
Set-PSReadlineKeyHandler -Key 'Ctrl+Spacebar' -Function MenuComplete

# PSFzf
#Import-Module PSFzf
#Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' #-PSReadlineChordReverseHistory 'Ctrl+r'

# Winget
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# Utilities
function which($command) {
	Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function pubip {
	(Invoke-WebRequest http://ifconfig.me/ip).Content
}

function rmreadline($command) {
    $history = Get-History
    $commandEntries = $history | Where-Object { $_.CommandLine -match $command }
    if ($commandEntries.Count -eq 0) {
        Write-Host "No matching commands found."
        return
    }
    foreach ($entry in $commandEntries) {
        Clear-History -Id $entry.Id
        Write-Host "Command deleted: $($entry.CommandLine)"
    }
}

function mklink {
    param(
        [string]$source,
        [string]$destination
    )
    New-Item -ItemType SymbolicLink -Path $source -Target $destination
}
function dotnet-tools-update {
    param (
        [switch]$global
    )

    try {
        # List dotnet tools
        if ($global) {
            $tools = dotnet tool list --global | Select-String "^\S+" | ForEach-Object { $_.Matches[0].Value }
        } else {
            $tools = dotnet tool list | Select-String "^\S+" | ForEach-Object { $_.Matches[0].Value }
        }

        if ($tools) {
            Write-Host "Updating..."
            foreach ($tool in $tools) {
                # Update dotnet tools
                try {
                    if ($global) {
                        dotnet tool update -g $tool -v diag
                    } else {
                        dotnet tool update $tool -v diag
                    }
                }
                catch {
                    Write-Host "Failed to update $($tool): $_"
                }
            }
            Write-Host "Update completed."
        }
        else {
            Write-Host "No dotnet tools to update found."
        }
    }
    catch {
        Write-Host "An error occurred: $_"
    }
}

# Utility functions for zoxide.
# Call zoxide binary, returning the output as UTF-8.
function global:__zoxide_bin {
    $encoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [System.Text.Utf8Encoding]::new()
        $result = zoxide @args
        return $result
    } finally {
        [Console]::OutputEncoding = $encoding
    }
}

# pwd based on zoxide's format.
function global:__zoxide_pwd {
    $cwd = Get-Location
    if ($cwd.Provider.Name -eq "FileSystem") {
        $cwd.ProviderPath
    }
}

# cd + custom logic based on the value of _ZO_ECHO.
function global:__zoxide_cd($dir, $literal) {
    $dir = if ($literal) {
        Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
    } else {
        if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1)) {
            Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
        }
        elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2)) {
            Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
        }
        else {
            Set-Location -Path $dir -Passthru -ErrorAction Stop
        }
    }
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
$global:__zoxide_oldpwd = __zoxide_pwd
function global:__zoxide_hook {
    $result = __zoxide_pwd
    if ($result -ne $global:__zoxide_oldpwd) {
        if ($null -ne $result) {
            zoxide add -- $result
        }
        $global:__zoxide_oldpwd = $result
    }
}

# Initialize hook.
$global:__zoxide_hooked = (Get-Variable __zoxide_hooked -ErrorAction SilentlyContinue -ValueOnly)
if ($global:__zoxide_hooked -ne 1) {
    $global:__zoxide_hooked = 1
    $global:__zoxide_prompt_old = $function:prompt

    function global:prompt {
        if ($null -ne $__zoxide_prompt_old) {
            & $__zoxide_prompt_old
        }
        $null = __zoxide_hook
    }
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function global:__zoxide_z {
    if ($args.Length -eq 0) {
        __zoxide_cd ~ $true
    }
    elseif ($args.Length -eq 1 -and ($args[0] -eq '-' -or $args[0] -eq '+')) {
        __zoxide_cd $args[0] $false
    }
    elseif ($args.Length -eq 1 -and (Test-Path $args[0] -PathType Container)) {
        __zoxide_cd $args[0] $true
    }
    else {
        $result = __zoxide_pwd
        if ($null -ne $result) {
            $result = __zoxide_bin query --exclude $result -- @args
        }
        else {
            $result = __zoxide_bin query -- @args
        }
        if ($LASTEXITCODE -eq 0) {
            __zoxide_cd $result $true
        }
    }
}

# Jump to a directory using interactive search.
function global:__zoxide_zi {
    $result = __zoxide_bin query -i -- @args
    if ($LASTEXITCODE -eq 0) {
        __zoxide_cd $result $true
    }
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force

# =============================================================================
#
# To initialize zoxide, add this to your configuration (find it by running
# `echo $profile` in PowerShell):
#
Invoke-Expression (& { (zoxide init powershell | Out-String) })
