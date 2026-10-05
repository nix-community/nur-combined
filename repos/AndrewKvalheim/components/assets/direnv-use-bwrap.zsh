# TODO: trash-cli, gio trash

_direnv_use_bwrap() {
  [[ "$DIRENV_USE_BWRAP" == "$PWD" ]] || return 0
  local dir="$PWD" previous_dir="$OLDPWD"
  local dir_id="$(systemd-escape --path "$dir")"

  local history_dir="$HOME/akorg/resource/shell-history-isolated/$dir_id"
  mkdir --parents "$history_dir"

  mkdir --parents "$DIRENV_USE_BWRAP_LAYOUT_DIR"

  local vscodium_dir="$HOME/.config/VSCodium-isolated/$dir_id"
  mkdir --parents "$vscodium_dir"

  local cache_dir="$HOME/.cache/isolated/$dir_id"
  mkdir --parents "$cache_dir"

  local ssh_dir="$HOME/.ssh/isolated/$dir_id"
  (umask 'go=rwx'; mkdir --parents "$ssh_dir")

  local -i etc_group; exec {etc_group}< <(getent group "$GID" 'nobody')
  local -i etc_passwd; exec {etc_passwd}< <(getent passwd "$UID" 'nobody')

  local bwrap_args=(
    --unshare-all
    --share-net
    --dev '/dev'
    --proc '/proc'
    --dir '/tmp'
    --file "$etc_group" '/etc/group'
    --file "$etc_passwd" '/etc/passwd'
    --dir "$XDG_RUNTIME_DIR"
    --bind "$history_dir" "$HOME/akorg/resource/shell-history"
    --bind "$vscodium_dir" "$HOME/.config/VSCodium"
    --bind "$cache_dir" "$HOME/.cache"
    --bind "$ssh_dir" "$HOME/.ssh"
  )
  local dev_try_paths=(
    '/dev/dri'
    '/dev/kfd'
  )
  for p in "${dev_try_paths[@]}"; bwrap_args+=(--dev-bind-try "$p" "$p")
  local rw_paths=(
    "$DIRENV_USE_BWRAP_LAYOUT_DIR"
    "$dir"
  )
  for p in "${rw_paths[@]}"; bwrap_args+=(--bind "$p" "$p")
  local ro_paths=(
    '/bin'
    '/etc/fonts'
    '/etc/gnupg'
    '/etc/resolv.conf'
    '/etc/ssl'
    '/etc/static/gnupg'
    '/etc/static/ssl'
    '/etc/zinputrc'
    '/etc/zshenv'
    '/etc/zshrc'
    '/lib'
    '/lib64'
    '/nix' # TODO: Narrow?
    '/usr/bin'
    "$HOME/.config/bat"
    "$HOME/.config/direnv"
    "$HOME/.config/git"
    "$HOME/.config/jj/config.toml"
    "$HOME/.config/jjui"
    "$HOME/.config/nixpkgs"
    "$HOME/.config/starship.toml"
    "$HOME/.config/VSCodium/User/keybindings.json"
    "$HOME/.config/VSCodium/User/settings.json"
    "$HOME/.config/zsh/abbreviations"
    "$HOME/.gnupg/gpg.conf"
    "$HOME/.gnupg/gpg-agent.conf"
    "$HOME/.gnupg/scdaemon.conf"
    "$HOME/.local/share/direnv"
    "$HOME/.local/state/nix"
    "$HOME/.nix-defexpr"
    "$HOME/.npmrc"
    "$HOME/.shellcheckrc"
    "$HOME/.vscode-oss"
    "$HOME/.zshenv"
    "$HOME/.zshrc"
    "$HOME/src/configuration"
    "$XDG_RUNTIME_DIR/gnupg"
  )
  if [[ -n "$DBUS_SESSION_BUS_ADDRESS" ]]; then
    local dbus_path="${${DBUS_SESSION_BUS_ADDRESS#unix:path=}%%,*}"; [[ -S "$dbus_path" ]]
    bwrap_args+=(--ro-bind "$XDG_RUNTIME_DIR/direnv-use-bwrap-dbus-proxy/bus" "$dbus_path")
  fi
  if [[ -n "$WAYLAND_DISPLAY" ]]; then
    ro_paths+=("$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY")
  fi
  if [[ -n "$DISPLAY" ]]; then
    ro_paths+=('/tmp/.X11-unix')
    if [[ -n "$XAUTHORITY" ]]; then
      ro_paths+=("$XAUTHORITY")
    fi
  fi
  for p in "${ro_paths[@]}"; bwrap_args+=(--ro-bind "$p" "$p")
  local ro_try_paths=(
    '/run/opengl-driver'
    ${(z)NIX_PROFILES}
  )
  for p in "${ro_try_paths[@]}"; bwrap_args+=(--ro-bind-try "$p" "$p")
  bwrap_args+=(
    --clearenv
    --setenv 'DIRENV_USING_BWRAP' "$dir"
  )
  local forward_env=(
    'DBUS_SESSION_BUS_ADDRESS'
    'DISPLAY'
    'HOME'
    'PATH'
    'TERM'
    'TERMINFO'
    'WAYLAND_DISPLAY'
    'XAUTHORITY'
    'XDG_RUNTIME_DIR'
  )
  if [[ -n "$DIRENV_USE_BWRAP_FORWARD_ENV" ]]; then
    for n in "${(z)DIRENV_USE_BWRAP_FORWARD_ENV}"; forward_env+=("$n")
  fi
  for n in "${forward_env[@]}"; [[ -z "${(P)${n}}" ]] || bwrap_args+=(--setenv "$n" "${(P)${n}}")

  bwrap "${bwrap_args[@]}" "$SHELL"

  exec $etc_group>&-
  exec $etc_passwd>&-
  cd -- "$previous_dir"
}

if [[ -z "$DIRENV_USING_BWRAP" ]]; then
  chpwd_functions+=(_direnv_use_bwrap)
fi
