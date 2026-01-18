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
  makeElectronWrapper = baseWrapper ''
    --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--wayland-text-input-version=3}}"
  '';
}
