{
  inputs',
  runCommand,
  rustPlatform,
}:
inputs'.niri.packages.default.overrideAttrs (
  finalAttrs: prevAttrs: {
    src = runCommand "${finalAttrs.pname}-patched-src" { } ''
      cp -r ${prevAttrs.src} $out
      pushd $out
        chmod -R +w .
        patch -p1 < ${./0001-input-Change-swipe-gesture-to-match-four-finger-usag.patch}
        patch -p1 < ${./remote-desktop.patch}
      popd
    '';
    buildFeatures = prevAttrs.buildFeatures ++ [ "xdp-gnome-remote-desktop" ];
    checkFeatures = finalAttrs.buildFeatures;
    cargoBuildFeatures = prevAttrs.cargoBuildFeatures ++ [ "xdp-gnome-remote-desktop" ];
    cargoCheckFeatures = finalAttrs.checkFeatures;
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src;
      hash = "sha256-aouPvpdxgmODvD8S/0moMde76XbfNuM1paQ21JsK0Pc=";
    };
    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
