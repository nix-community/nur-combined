export ZAUTOLOADDIR=~/.zsh.d

PIM_ZSH_DEBUG=false
PIM_ZSH_PROFILER=false

G_RESOURCE_OVERLAYS="/org/gnome/nautilus/ui=$HOME/.config/nautilus/ui"

function echo_debug {
  if [ "$PIM_ZSH_DEBUG" = true ] ; then
    echo $1
  fi
}

function print_env_vars {
  if [ "$PIM_ZSH_DEBUG" = true ] ; then
    vars=('PATH' 'ZAUTOLOADDIR' 'ZDOTDIR' 'RBENV' )
    for var in $vars; do
      echo "$var=${(P)var}"
    done
  fi
}
if [ -e /Users/pim/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/pim/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
