{
  wrapShellScriptBin,
  coreutils, inetutils, curl, jq, xrandr ? null, feh ? null, xsetroot ? null, sway ? null,
  hostPlatform, lib,
  swaySupport ? hostPlatform.isLinux,
  xorgSupport ? hostPlatform.isLinux
}:

assert swaySupport -> sway != null;
assert xorgSupport -> (feh != null && xsetroot != null && xrandr != null);

wrapShellScriptBin "konawall" ./konawall.sh {
  depsRuntimePath = with lib; [coreutils inetutils curl jq] ++
    optionals xorgSupport [feh xsetroot xrandr] ++
    optionals swaySupport [sway];
}
