{
  fetchurl,
  lib,
  googleearth-pro,
}:
googleearth-pro.overrideAttrs (old: {
  pname = "google-earth-pro";
  version = "7.3.7.1155";
  src = fetchurl {
    url = "https://dl.google.com/linux/earth/deb/pool/main/g/google-earth-pro-stable/google-earth-pro-stable_7.3.7.1155-r0_amd64.deb";
    hash = "sha256-lWFGpO4fCywxK/najHzFQoftfCEFiYX/31nloJSzCyM=";
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
  };
})
