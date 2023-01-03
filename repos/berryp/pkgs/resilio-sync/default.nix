{
  lib,
  stdenv,
  fetchurl,
  undmg,
}:
stdenv.mkDerivation rec {
  pname = "resilio-sync";
  version = "2.7.3";

  src = fetchurl {
    url = "https://download-cdn.resilio.com/${version}/osx/Resilio-Sync.dmg";
    sha256 = "sha256-pRFP8Eyk86ggeYAsFoPBQYiArAoGinQ4hcozs0kpbWo=";
  };

  outputs = ["out"];

  nativeBuildInputs = [undmg];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r "Resilio Sync.app" $out/Applications
  '';

  meta = with lib; {
    description = "Automatically sync files via secure, distributed technology";
    homepage = "https://www.resilio.com/";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.unfreeRedistributable;
    platforms = ["aarch64-darwin" "x86_64-darwin"];
    maintainers = with maintainers; [berryp];
  };
}