#!/usr/bin/env bash
set -euo pipefail

profile=$1
expected_startup=$2
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

# Replace the compositor with a marker; never launch a graphical session.
printf '#!%s\nprintf "hyprland\\n"\n' "$BASH" > "$test_dir/start-hyprland"
chmod +x "$test_dir/start-hyprland"

check_login() {
  local expected=$1 terminal=$2 session=$3 display=$4 wayland=$5 interactive=$6
  local actual shell_flags=-c
  if [[ $interactive == yes ]]; then
    shell_flags=-ic
  fi

  # Expand the script in the child shell, after setting its session environment.
  # shellcheck disable=SC2016
  actual=$(env PATH="$test_dir:$PATH" TEST_TTY="$terminal" \
    XDG_SESSION_TYPE="$session" DISPLAY="$display" WAYLAND_DISPLAY="$wayland" \
    bash --noprofile --norc "$shell_flags" '
      tty() { printf "%s\n" "$TEST_TTY"; }
      source "$1"
      printf "shell\n"
    ' bash "$profile" 2> "$test_dir/stderr")

  if [[ $actual != "$expected" ]]; then
    printf 'Unexpected login result: tty=%s session=%s interactive=%s expected=%s actual=%s\n' \
      "$terminal" "$session" "$interactive" "$expected" "$actual" >&2
    cat "$test_dir/stderr" >&2
    return 1
  fi
}

check_login "$expected_startup" /dev/tty1 tty '' '' yes
check_login shell /dev/tty2 tty '' '' yes
check_login shell /dev/pts/0 tty '' '' yes
check_login shell /dev/tty1 wayland '' '' yes
check_login shell /dev/tty1 x11 '' '' yes
check_login shell /dev/tty1 '' '' '' yes
check_login shell /dev/tty1 tty :0 '' yes
check_login shell /dev/tty1 tty '' wayland-0 yes
check_login shell /dev/tty1 tty '' '' no
