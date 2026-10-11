{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../default.nix { inherit pkgs; }).mnamer-rs,
}:
pkgs.runCommand "mnamer-rs-packaging-check" { } ''
  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$HOME/config"
  export XDG_CACHE_HOME="$HOME/cache"
  mkdir -p "$HOME"
  test -x ${package}/bin/mnamer
  ${package}/bin/mnamer version > version.txt
  grep -Fx ${pkgs.lib.escapeShellArg "mnamer ${package.version}"} version.txt
  ${package}/bin/mnamer help > /dev/null
  ${package}/bin/mnamer help move > /dev/null
  touch "$out"
''
