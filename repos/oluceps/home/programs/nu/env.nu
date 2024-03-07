# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# The prompt indicators are environmental variables that represent
# the state of the prompt

def create_prompt [p] {
    let gold = {fg: '#f1c4cd'}
    let home = $env.HOME | str trim
    let in_home = pwd | str starts-with $home
    let path = if $in_home {
        pwd | str replace $home '~'
    }
    $'(ansi blue)($path) (ansi reset)(ansi --escape $gold)(do -i {git rev-parse --abbrev-ref HEAD } | str trim | str join)(ansi reset)(char newline)(ansi cyan)($p)(ansi reset)'
}


$env.PROMPT_INDICATOR = {|| "" }
$env.PROMPT_COMMAND_RIGHT = {|| ""}
$env.PROMPT_COMMAND = {|| ""}
$env.PROMPT_INDICATOR_VI_INSERT = {|| create_prompt "> " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| create_prompt "< " }
$env.PROMPT_MULTILINE_INDICATOR = {|| create_prompt "::" }

$env.EDITOR = "hx"
$env.VISUAL = "hx"

