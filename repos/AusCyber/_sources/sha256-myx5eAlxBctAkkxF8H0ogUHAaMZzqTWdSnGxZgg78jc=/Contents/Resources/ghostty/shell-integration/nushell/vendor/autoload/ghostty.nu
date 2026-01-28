# Ghostty shell integration
export module ghostty {
  def has_feature [feature: string] {
    $feature in ($env.GHOSTTY_SHELL_FEATURES | default "" | split row ',')
  }

  # Enables automatic terminfo installation on remote hosts.
  # Attempts to install Ghostty's terminfo entry using infocmp and tic when
  # connecting to hosts that lack it. 
  # Requires infocmp to be available locally and tic to be available on remote hosts.
  # Caches installations to avoid repeat installations.
  def set_ssh_terminfo [
    ssh_opts: list<string>
    ssh_args: list<string>
  ]: [nothing -> record<ssh_term: string, ssh_opts: list<string>>] {
    let ssh_cfg = ^ssh -G ...($ssh_args)
      | lines
      | parse "{key} {value}"
      | where key in ["user" "hostname"]
      | select key value
      | transpose -rd
      | default {user: $env.USER hostname: "localhost"}

    let ssh_id = $"($ssh_cfg.user)@($ssh_cfg.hostname)"
    let ghostty_bin = $env.GHOSTTY_BIN_DIR | path join "ghostty"

    let is_cached = (
      ^$ghostty_bin ...(["+ssh-cache" $"--host=($ssh_id)"])
      | complete
      | $in.exit_code == 0
    )

    if not $is_cached {
      let terminfo_data = try { ^infocmp -0 -x xterm-ghostty } catch {
        print "Warning: Could not generate terminfo data."
        return {ssh_term: "xterm-256color" ssh_opts: $ssh_opts}
      }

      print $"Setting up xterm-ghostty terminfo on ($ssh_cfg.hostname)..."

      let ctrl_path = (
        mktemp -td $"ghostty-ssh-($ssh_cfg.user).XXXXXX"
        | path join "socket"
      )

      let master_parts = $ssh_opts ++ ["-o" "ControlMaster=yes" "-o" $"ControlPath=($ctrl_path)" "-o" "ControlPersist=60s"] ++ $ssh_args

      ($terminfo_data) | ^ssh ...(
        $master_parts ++
        [
          '
        infocmp xterm-ghostty >/dev/null 2>&1 && exit 0
        command -v tic >/dev/null 2>&1 || exit 1
        mkdir -p ~/.terminfo 2>/dev/null && tic -x - 2>/dev/null && exit 0
        exit 1'
        ]
      )
      | complete
      | if $in.exit_code != 0 {
        print "Warning: Failed to install terminfo."
        return {ssh_term: "xterm-256color" ssh_opts: $ssh_opts}
      }

      ^$ghostty_bin ...(["+ssh-cache" $"--add=($ssh_id)"]) o+e>| ignore

      return {ssh_term: "xterm-ghostty" ssh_opts: ($ssh_opts ++ ["-o" $"ControlPath=($ctrl_path)"])}
    }

    return {ssh_term: "xterm-ghostty" ssh_opts: $ssh_opts}
  }

  # Wrap `ssh` with Ghostty TERMINFO support
  export def --wrapped ssh [...ssh_args: string]: any -> any {
    if ($ssh_args | is-empty) {
      return (^ssh)
    }
    # `ssh-env` enables SSH environment variable compatibility.
    # Converts TERM from xterm-ghostty to xterm-256color
    # and propagates COLORTERM, TERM_PROGRAM, and TERM_PROGRAM_VERSION
    # Check your sshd_config on remote host to see if these variables are accepted
    let base_ssh_opts = if (has_feature "ssh-env") {
      ["-o" "SetEnv COLORTERM=truecolor" "-o" "SendEnv TERM_PROGRAM TERM_PROGRAM_VERSION"]
    } else {
      []
    }
    let base_ssh_term = if (has_feature "ssh-env") {
      "xterm-256color"
    } else {
      ($env.TERM? | default "")
    }

    let session = if (has_feature "ssh-terminfo") {
      set_ssh_terminfo $base_ssh_opts $ssh_args
    } else {
      {ssh_term: $base_ssh_term ssh_opts: $base_ssh_opts}
    }

    with-env {TERM: $session.ssh_term} {
      ^ssh ...($session.ssh_opts ++ $ssh_args)
    }
  }

  # Wrap `sudo` to preserve Ghostty's TERMINFO environment variable
  export def --wrapped sudo [
    ...args # Arguments to pass to `sudo`
  ] {
    mut sudo_args = $args

    if (has_feature "sudo") {
      # Extract just the sudo options (before the command)
      let sudo_options = (
        $args | take until {|arg|
          not (($arg | str starts-with "-") or ($arg | str contains "="))
        }
      )

      # Prepend TERMINFO preservation flag if not using sudoedit
      if (not ("-e" in $sudo_options or "--edit" in $sudo_options)) {
        $sudo_args = ($args | prepend "--preserve-env=TERMINFO")
      }
    }

    ^sudo ...$sudo_args
  }
}

# Clean up XDG_DATA_DIRS by removing GHOSTTY_SHELL_INTEGRATION_XDG_DIR
if 'GHOSTTY_SHELL_INTEGRATION_XDG_DIR' in $env {
  if 'XDG_DATA_DIRS' in $env {
    $env.XDG_DATA_DIRS = ($env.XDG_DATA_DIRS | str replace $"($env.GHOSTTY_SHELL_INTEGRATION_XDG_DIR):" "")
  }
  hide-env GHOSTTY_SHELL_INTEGRATION_XDG_DIR
}
