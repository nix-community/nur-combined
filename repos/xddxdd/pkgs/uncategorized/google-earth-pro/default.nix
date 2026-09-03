{
  fetchurl,
  lib,
  googleearth-pro,
}:
let
  version = "7.3.7.1327";
in
googleearth-pro.overrideAttrs (old: {
  pname = "google-earth-pro";
  inherit version;
  src = fetchurl {
    url = "https://dl.google.com/linux/earth/deb/pool/main/g/google-earth-pro-stable/google-earth-pro-stable_${version}-r0_amd64.deb";
    hash = "sha256-ynVnHveF5hPQwkvu+RRCnAR+rEhkG3x5+8EbQv77C3o=";
  };
  unpackPhase = ''
    runHook preUnpack

    # deb file contains a setuid binary, so 'dpkg -x' doesn't work here
    mkdir deb
    dpkg --fsys-tarfile $src | tar --extract -C deb

    runHook postUnpack
  '';
  passthru.updateScript = [ (toString ./update.sh) ];
  meta = (builtins.removeAttrs old.meta [ "knownVulnerabilities" ]) // {
    mainProgram = "googleearth-pro";
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = [ "x86_64-linux" ];
    description = "Google Earth Pro";
  };
})
