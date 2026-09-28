#!@runtimeShell@
set -e
PATH="@coreutils@/bin:$PATH"
# The emulator checks presence only; translate an explicit 0 to unset.
if [ "$TOUCHHLE_IAP_EMULATION" = 0 ]; then
  unset TOUCHHLE_IAP_EMULATION
else
  export TOUCHHLE_IAP_EMULATION=1
fi
if [ -n "$WAYLAND_DISPLAY" ]; then
  export SDL_VIDEODRIVER=wayland
fi
if [ -n "$XDG_DATA_HOME" ]; then
  data_dir="$XDG_DATA_HOME/hyperhle-fork"
else
  data_dir="$HOME/.local/share/hyperhle-fork"
fi
mkdir -p "$data_dir/touchHLE_apps"
resource_dir="@resources@"
for name in touchHLE_dylibs touchHLE_fonts touchHLE_default_options.txt; do
  if [ -L "$data_dir/$name" ]; then
    ln -sfnT "$resource_dir/$name" "$data_dir/$name"
  elif [ ! -e "$data_dir/$name" ]; then
    ln -s "$resource_dir/$name" "$data_dir/$name"
  fi
done
if [ "$#" -gt 0 ] && [ -e "$1" ]; then
  app_path="$(realpath "$1")"
  shift
  set -- "$app_path" "$@"
fi
cd "$data_dir"
exec "@unwrapped@/bin/touchHLE" "$@"
