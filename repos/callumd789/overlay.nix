# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.
#
# It builds each package against the nixpkgs it's applied to, so nothing is
# cached for it. The flake's `overlays.default` puts the same attributes in
# the same places, using the packages CI builds and caches instead.
#
# Each package goes where nixpkgs would put it: tmux plugins extend
# pkgs.tmuxPlugins rather than sitting at the top level.

final: prev:
let
  nurPkgs = import ./default.nix { pkgs = final; };
in
{
  inherit (nurPkgs) rustconn tmux-agent-sidebar;

  tmuxPlugins = prev.tmuxPlugins // {
    tmux-agent-sidebar = nurPkgs.tmux-agent-sidebar-plugin;
  };
}
