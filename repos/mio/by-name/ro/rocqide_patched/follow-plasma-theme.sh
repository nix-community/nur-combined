# Sourced by the RocqIDE wrapper before exec.
# Detect KDE Plasma / freedesktop color-scheme preference and export:
#   ROCQIDE_PREFER_DARK=0|1
#   GTK_THEME=Adwaita:dark  (only when dark and GTK_THEME is unset)
#
# Prefer-dark is color-scheme uint32 1 per org.freedesktop.Appearance.
# Uses only shell builtins + dbus-send (optional) so a minimal PATH is fine.

rocqide_prefer_dark() {
  # Explicit override wins.
  case "${ROCQIDE_PREFER_DARK-}" in
    1|true|yes|YES|True) return 0 ;;
    0|false|no|NO|False) return 1 ;;
  esac

  # 1) xdg-desktop-portal (Plasma 5.27+ / 6 expose this)
  if command -v dbus-send >/dev/null 2>&1; then
    _reply=$(dbus-send --print-reply --session \
      --dest=org.freedesktop.portal.Desktop \
      /org/freedesktop/portal/desktop \
      org.freedesktop.portal.Settings.Read \
      string:'org.freedesktop.appearance' string:'color-scheme' 2>/dev/null) || _reply=
    case "$_reply" in
      *'uint32 1'*) return 0 ;;
      *'uint32 2'*) return 1 ;;
    esac
  fi

  _cfg="${XDG_CONFIG_HOME:-${HOME:-}/.config}"

  # 2) Plasma gtk-3 settings written by kde-gtk-config
  if [ -f "$_cfg/gtk-3.0/settings.ini" ]; then
    while IFS= read -r _line || [ -n "$_line" ]; do
      case "$_line" in
        gtk-application-prefer-dark-theme=*)
          _val=${_line#gtk-application-prefer-dark-theme=}
          _val=${_val#"${_val%%[![:space:]]*}"}
          case "$_val" in
            1|[Tt]rue|[Tt]RUE) return 0 ;;
          esac
          ;;
      esac
    done < "$_cfg/gtk-3.0/settings.ini"
  fi

  # 3/4) Plasma kdeglobals: ColorScheme name, else window bg luminance
  if [ -f "$_cfg/kdeglobals" ]; then
    _scheme=
    _bg=
    _in_window=
    while IFS= read -r _line || [ -n "$_line" ]; do
      case "$_line" in
        ColorScheme=*)
          [ -z "$_scheme" ] && _scheme=${_line#ColorScheme=}
          ;;
        '[Colors:Window]')
          _in_window=1
          ;;
        \[*)
          _in_window=
          ;;
        BackgroundNormal=*)
          if [ -n "$_in_window" ] && [ -z "$_bg" ]; then
            _bg=${_line#BackgroundNormal=}
          fi
          ;;
      esac
    done < "$_cfg/kdeglobals"

    case "$_scheme" in
      *[Dd]ark*) return 0 ;;
      *[Ll]ight*) return 1 ;;
    esac

    # ITU-R BT.601 luma of BackgroundNormal; < 128 => dark
    if [ -n "$_bg" ]; then
      _r=${_bg%%,*}
      _rest=${_bg#*,}
      _g=${_rest%%,*}
      _b=${_rest#*,}
      _b=${_b%%,*}
      # trim spaces
      _r=${_r#"${_r%%[![:space:]]*}"}
      _r=${_r%"${_r##*[![:space:]]}"}
      _g=${_g#"${_g%%[![:space:]]*}"}
      _g=${_g%"${_g##*[![:space:]]}"}
      _b=${_b#"${_b%%[![:space:]]*}"}
      _b=${_b%"${_b##*[![:space:]]}"}
      if [ -n "$_r" ] && [ -n "$_g" ] && [ -n "$_b" ]; then
        _y=$(( (299 * _r + 587 * _g + 114 * _b) / 1000 ))
        if [ "$_y" -lt 128 ]; then
          return 0
        else
          return 1
        fi
      fi
    fi
  fi

  return 1
}

if rocqide_prefer_dark; then
  export ROCQIDE_PREFER_DARK=1
  # Force a dark GTK variant so chrome matches Plasma dark and symbolic
  # Breeze-Dark icons stay visible (light glyphs on a dark background).
  # Leave an explicit user GTK_THEME alone.
  if [ -z "${GTK_THEME-}" ]; then
    export GTK_THEME=Adwaita:dark
  fi
else
  export ROCQIDE_PREFER_DARK=0
fi
