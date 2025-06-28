{
  sources,
  lib,
  googleearth-pro,
  callPackage,
}:
let
  libxml2 = callPackage ./libxml2.nix { };
in
(googleearth-pro.override { inherit libxml2; }).overrideAttrs (old: {
  inherit (sources.google-earth-pro) pname version src;
  unpackPhase = ''
    runHook preUnpack

    # deb file contains a setuid binary, so 'dpkg -x' doesn't work here
    mkdir deb
    dpkg --fsys-tarfile $src | tar --extract -C deb

    runHook postUnpack
  '';
  meta = (builtins.removeAttrs old.meta [ "knownVulnerabilities" ]) // {
    mainProgram = "googleearth-pro";
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = [ "x86_64-linux" ];
  };
})
