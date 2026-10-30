_direnv_use_bwrap() {
  [[ -v DIRENV_USE_BWRAP && "$PWD/" == "$DIRENV_USE_BWRAP/"* ]] || return 0

  (
    setopt errexit nounset pipefail

    set -- ${(Q)${(z)DIRENV_USE_BWRAP_ARGS}}
    zparseopts -D -F -- \
      -allow-env+:=allow_env \
      -allow-gopass+:=allow_gopass \
      -allow-ro+:=allow_ro \
      -allow-rw+:=allow_rw

    local id="$(systemd-escape --path "$DIRENV_USE_BWRAP")"
    local -aU create_dir expose_env expose_ns expose_path_ro expose_path_rw maybe_expose_path_ro
    local -A expose_fd_as expose_path_ro_as expose_path_rw_as maybe_expose_path_ro_as set_env

    #
    # Components
    #

    # Common
    expose_env+=(
      'HOME'
      'PATH'
      'XDG_RUNTIME_DIR'
    )
    if [[ -v XDG_RUNTIME_DIR ]] create_dir+=("$XDG_RUNTIME_DIR")

    # Sensors
    expose_path_ro+=(
      '/sys/class/power_supply'
      '/sys/class/thermal'
    )

    # Nix
    expose_path_ro+=(
      '/nix' # TODO: Narrow?
      "$HOME/.config/nixpkgs"
      "$HOME/.local/state/nix"
      "$HOME/.nix-defexpr"
      "$HOME/src/configuration"
    )
    maybe_expose_path_ro+=(
      ${(z)NIX_PROFILES}
    )

    # FHS compatibility
    expose_path_ro+=(
      '/bin'
      '/lib'
      '/lib64'
      '/usr/bin'
    )

    # Networking
    expose_ns+=(
      'net'
    )
    expose_path_ro+=(
      '/etc/resolv.conf'
      '/etc/ssl'
      '/etc/static/ssl'
    )

    # NSS
    local -i etc_passwd; exec {etc_passwd}< <(getent passwd "$UID" 'nobody')
    expose_fd_as[$etc_passwd]='/etc/passwd'
    local -i etc_group; exec {etc_group}< <(getent group "$GID" 'nobody')
    expose_fd_as[$etc_group]='/etc/group'

    # D-Bus
    expose_path_ro_as[$XDG_RUNTIME_DIR/direnv-use-bwrap-dbus-proxy/system]='/run/dbus/system_bus_socket'
    expose_env+=(
      'DBUS_SESSION_BUS_ADDRESS'
    )
    if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
      local dbus_path="${${DBUS_SESSION_BUS_ADDRESS#unix:path=}%%,*}"; [[ -S "$dbus_path" ]]
      expose_path_ro_as[$XDG_RUNTIME_DIR/direnv-use-bwrap-dbus-proxy/session]="$dbus_path"
    fi

    # Trash
    # TODO: trash-cli, gio trash

    # GNOME
    expose_env+=(
      'GDMSESSION'
      'XDG_CURRENT_DESKTOP'
      'XDG_SESSION_TYPE'
    )

    # Wayland
    expose_env+=(
      'WAYLAND_DISPLAY'
    )
    if [[ -v WAYLAND_DISPLAY ]] expose_path_ro+=("$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY")

    # X11
    expose_env+=(
      'DISPLAY'
      'XAUTHORITY'
    )
    if [[ -v DISPLAY ]] expose_path_ro+=('/tmp/.X11-unix')
    if [[ -v XAUTHORITY ]] expose_path_ro+=("$XAUTHORITY")

    # Cache
    expose_path_rw_as[$(_direnv_use_bwrap::dir "$HOME/.cache/isolated/$id")]="$HOME/.cache"

    # direnv
    set_env[DIRENV_USING_BWRAP]="$DIRENV_USE_BWRAP"
    expose_path_ro+=(
      "$HOME/.config/direnv"
      "$HOME/.local/share/direnv"
    )
    expose_path_rw+=(
      "$(_direnv_use_bwrap::dir "$DIRENV_USE_BWRAP_LAYOUT_DIR")"
    )

    # Shell
    expose_path_ro+=(
      '/etc/zinputrc'
      '/etc/zshenv'
      '/etc/zshrc'
      "$HOME/.config/bat"
      "$HOME/.config/starship.toml"
      "$HOME/.config/zsh/abbreviations"
      "$HOME/.zshenv"
      "$HOME/.zshrc"
    )
    expose_path_rw_as[$(_direnv_use_bwrap::dir "$HOME/akorg/resource/shell-history-isolated/$id")]="$HOME/akorg/resource/shell-history"
    expose_env+=(
      'TERM'
      'TERMINFO'
    )

    # OpenPGP
    expose_path_ro+=(
      '/etc/gnupg'
      '/etc/static/gnupg'
      "$HOME/.gnupg/gpg.conf"
      "$HOME/.gnupg/gpg-agent.conf"
      "$HOME/.gnupg/scdaemon.conf"
      "$XDG_RUNTIME_DIR/gnupg"
    )
    expose_path_rw_as[$(_direnv_use_bwrap::gnupg_dir "$id")]="$HOME/.gnupg"

    # SSH
    expose_path_rw_as[$(_direnv_use_bwrap::ssh_dir "$id")]="$HOME/.ssh"

    # Git
    expose_path_ro+=(
      "$HOME/.config/git"
      "$HOME/.config/jj/config.toml"
      "$HOME/.config/jjui"
    )

    # Password store
    if (( #allow_gopass > 0 )); then
      local password_store_path="$(gopass config 'mounts.path')"
      expose_path_ro+=(
        "$HOME/.config/gopass"
        "$password_store_path/.gpg-id"
      )
      for _ p in "${(@)allow_gopass}"; expose_path_ro+=("$password_store_path/$p.gpg")
    fi

    # NPM
    expose_path_ro+=(
      "$HOME/.npmrc"
    )

    # VSCodium
    expose_dev+=(
      '/dev/dri'
      '/dev/kfd'
    )
    expose_path_ro+=(
      '/etc/fonts'
      '/run/opengl-driver'
      '/sys/dev/char'
      '/sys/devices'
      "$HOME/.config/VSCodium/User/keybindings.json"
      "$HOME/.config/VSCodium/User/settings.json"
      "$HOME/.shellcheckrc"
      "$HOME/.vscode-oss"
    )
    expose_path_rw_as[$(_direnv_use_bwrap::dir "$HOME/.config/VSCodium-isolated/$id")]="$HOME/.config/VSCodium"

    # Project
    expose_path_rw+=(
      "$DIRENV_USE_BWRAP"
    )
    for _ p in "${(@)allow_ro}"; expose_path_ro+=("${p:a}")
    for _ p in "${(@)allow_rw}"; expose_path_rw+=("${p:a}")
    for _ n in "${(@)allow_env}"; expose_env+=("$n")

    #
    # bwrap
    #

    local bwrap_args=(
      --unshare-all
      --clearenv
      --dev '/dev'
      --proc '/proc'
      --dir '/tmp'
    )
    for p in "${create_dir[@]}"; bwrap_args+=(--dir "$p")
    for n in "${expose_ns[@]}"; bwrap_args+=("--share-$n")
    for p in "${expose_path_rw[@]}"; expose_path_rw_as[$p]="$p"
    for f p in ${(kv)expose_path_rw_as}; bwrap_args+=(--bind "$f" "$p")
    for p in "${expose_dev[@]}"; bwrap_args+=(--dev-bind "$p" "$p")
    for d p in ${(kv)expose_fd_as}; bwrap_args+=(--file "$d" "$p")
    for p in "${expose_path_ro[@]}"; expose_path_ro_as[$p]="$p"
    for f p in ${(kv)expose_path_ro_as}; bwrap_args+=(--ro-bind "$f" "$p")
    for p in "${maybe_expose_path_ro[@]}"; maybe_expose_path_ro_as[$p]="$p"
    for f p in ${(kv)maybe_expose_path_ro_as}; bwrap_args+=(--ro-bind-try "$f" "$p")
    for e in "${expose_env[@]}"; [[ -z "${(P)${e}}" ]] || set_env[$e]="${(P)${e}}"
    for e v in ${(kv)set_env}; bwrap_args+=(--setenv "$e" "$v")
    bwrap_args+=(-- "$SHELL")

    if [[ -v DIRENV_USE_BWRAP_VERBOSE ]] typeset -p bwrap_args
    bwrap "${bwrap_args[@]}"

    for d in ${(k)expose_fd_as}; exec {d}>&-
  ) || echo 'Failed to use bwrap' >&2

  cd -- "$OLDPWD"
}

_direnv_use_bwrap::dir() { dir="$1"
  mkdir --parents "$dir"

  print -r -- "$dir"
}

_direnv_use_bwrap::gnupg_dir() { local id="$1"
  local dir="$HOME/.gnupg/isolated/$id"

  umask '077'
  mkdir --parents "$dir"
  <@openpgp-key-path@ GNUPGHOME="$dir" gpg --batch --import --quiet

  print -r -- "$dir"
}

_direnv_use_bwrap::ssh_dir() { local id="$1"
  local dir="$HOME/.ssh/isolated/$id"

  umask '077'
  mkdir --parents "$dir"
  [[ -f "$dir/config" ]] || echo 'PreferredAuthentications publickey' > "$dir/config"

  print -r -- "$dir"
}

if [[ ! -v DIRENV_USING_BWRAP ]]; then
  chpwd_functions+=(_direnv_use_bwrap)
fi
