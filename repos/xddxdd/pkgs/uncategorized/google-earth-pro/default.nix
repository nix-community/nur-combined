{
  sources,
  lib,
  googleearth-pro,
  libxml2,
  fetchurl,
}:
let
  libxml2' = libxml2.overrideAttrs rec {
    version = "2.13.8";
    src = fetchurl {
      url = "mirror://gnome/sources/libxml2/${lib.versions.majorMinor version}/libxml2-${version}.tar.xz";
      hash = "sha256-J3KUyzMRmrcbK8gfL0Rem8lDW4k60VuyzSsOhZoO6Eo=";
    };
  };
in
(googleearth-pro.override { libxml2 = libxml2'; }).overrideAttrs (old: {
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
