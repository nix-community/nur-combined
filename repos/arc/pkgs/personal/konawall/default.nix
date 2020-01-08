{
  wrapShellScriptBin,
  coreutils, inetutils, curl, jq, gnugrep ? null, xrandr ? null, feh ? null, xsetroot ? null, sway ? null,
  hostPlatform, lib,
  swaySupport ? false,
  xorgSupport ? hostPlatform.isLinux
}:

assert swaySupport -> sway != null;
assert xorgSupport -> (feh != null && xsetroot != null && xrandr != null);

wrapShellScriptBin "konawall" ./konawall.sh {
  depsRuntimePath = with lib; [coreutils inetutils curl jq] ++
    optionals xorgSupport [feh xsetroot xrandr gnugrep] ++
    optionals swaySupport [sway];
}
