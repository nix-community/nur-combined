final: prev:
let
  baseWrapper = wrapArgs: pkg: final.symlinkJoin {
    name = final.lib.getName pkg;
    paths = [ pkg ];
    buildInputs = [ final.makeWrapper ];
    postBuild = ''
      for program in $out/bin/*; do
        wrapProgram $program ${wrapArgs}
      done
    '';
  };
in
{
  inherit baseWrapper;
  makeNoProxyWrapper = baseWrapper ''
    --unset all_proxy   \
    --unset https_proxy \
    --unset http_proxy  \
    --unset ftp_proxy   \
    --unset rsync_proxy \
    --unset no_proxy    \
    --unset RES_OPTIONS
  '';
  makeElectronWrapper = baseWrapper ''
    --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--wayland-text-input-version=3}}"
  '';
}
