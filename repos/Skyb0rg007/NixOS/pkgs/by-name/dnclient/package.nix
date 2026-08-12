{
  lib,
  fetchurl,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dnclient";
  version = "0.9.7";

  src = fetchurl {
    url = "https://dl.defined.net/stable/binaries/dnclient/v${finalAttrs.version}/linux/amd64/dnclient";
    hash = "sha256-Nz9+lH1BREGDcuGfi9zt/ygY3/hFbf8H7DHmLQy0bsM=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -d $out/bin
    install -m755 $src $out/bin/dnclient
  '';

  meta = {
    homepage = "https://www.defined.net/";
    downloadPage = "https://www.defined.net/downloads/";
    changelog = "https://docs.defined.net/dnclient-changelog/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ]; # XXX: more
  };
})
