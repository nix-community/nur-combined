{
  inputs,
  stdenv,
  runCommand,
  sources,
  rustPlatform,
}:
let
  package =
    inputs.niri.packages.${stdenv.hostPlatform.system} or inputs.niri.packages.x86_64-linux or null;
in
if package != null then
  package.default.overrideAttrs (
    finalAttrs: prevAttrs: {
      src = runCommand "${finalAttrs.pname}-patched-src.tar.gz" { } ''
        cp -r ${prevAttrs.src} source
        pushd source
          chmod -R +w .
          patch -p1 < ${./0001-input-Change-swipe-gesture-to-match-four-finger-usag.patch}
          patch -p1 < ${./remote-desktop.patch}
        popd

        tar -czf $out source
      '';
      unpackPhase = ''
        runHook preUnpack
        tar -xzf $src --strip-components=1
        runHook postUnpack
      '';
      buildFeatures = prevAttrs.buildFeatures ++ [ "xdp-gnome-remote-desktop" ];
      checkFeatures = finalAttrs.buildFeatures;
      cargoBuildFeatures = prevAttrs.cargoBuildFeatures ++ [ "xdp-gnome-remote-desktop" ];
      cargoCheckFeatures = finalAttrs.checkFeatures;
      cargoDeps = rustPlatform.importCargoLock sources.niri.cargoLock."Cargo.lock";
      passthru = (prevAttrs.passthru or { }) // {
        _ignoreOverride = true;
      };
    }
  )
else
  null
