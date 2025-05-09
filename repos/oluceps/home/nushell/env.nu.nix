{
  lib,
  pkgs,
  user,
  ...
}:
''
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

  let branch_gold = {fg: '#F17C67'}
  let host_sprout = {fg: '#B5CAB9'}
  let rev_pink = {fg: '#C8ADC4'}
  let path_blue = {fg: '#2168F5'}
  let prom_gray = {fg: '#ACB0BE'}


  def create_right_prompt [] {
    let home = $env.HOME | str trim
    let in_home = pwd | str starts-with $home
    let path = if $in_home {
        pwd | str replace $home '~'
    }
    mut prompt = $'(ansi $path_blue)($path)(ansi reset) ';
    if (".git" | path exists) {
      $prompt += $'(ansi $branch_gold)( git rev-parse --abbrev-ref HEAD | str trim )(ansi reset)'
      $prompt += (char space)
      $prompt += $'(ansi $rev_pink)( git rev-parse --short=8 HEAD | str trim )(ansi reset)'
      $prompt += (char space)
    }
    return ($prompt + $'(ansi $host_sprout)(hostname)(ansi reset)')
  }

  $env.PROMPT_INDICATOR = {|| "> " }
  $env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }
  $env.PROMPT_COMMAND = {|| ""}
  $env.PROMPT_INDICATOR_VI_INSERT = {|| if ($env.LAST_EXIT_CODE != 0) {$"(ansi red)>(ansi reset) "} else {$"(ansi $prom_gray)>(ansi reset) "}}
  $env.PROMPT_INDICATOR_VI_NORMAL = {|| $"(ansi blue)<(ansi reset) " }
  $env.PROMPT_MULTILINE_INDICATOR = {|| "::" }

  $env.LS_COLORS = (${lib.getExe pkgs.vivid} generate rose-pine-dawn)


  $env.EDITOR = "hx"
  $env.VISUAL = "hx"
  $env.config.edit_mode = 'vi'
  $env.config.buffer_editor = "hx"
  $env.config.show_banner = false



  let atuin_cache = "/home/${user}/.cache/atuin"

  if not ($atuin_cache | path exists) {
    mkdir $atuin_cache
  }

  /run/current-system/sw/bin/atuin init nu  | save --force $'($atuin_cache)/init.nu'
  source ~/.cache/atuin/init.nu
''
