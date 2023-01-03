{
  lib,
  stdenv,
  fetchurl,
  undmg,
}: let
  arch = lib.strings.removeSuffix "-darwin" stdenv.system;
in
  stdenv.mkDerivation rec {
    pname = "rancher-desktop";
    version = "1.7.0";

    src = fetchurl {
      url = "https://github.com/rancher-sandbox/rancher-desktop/releases/download/v${version}/Rancher.Desktop-${version}.${arch}.dmg";
      sha256 = "sha256-go3eRIaMPDP+cJ4Jn5rwgBQ6N5+fui47rNhkH1rY5ys=";
    };

    nativeBuildInputs = [undmg];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/Applications
      cp -R Rancher\ Desktop.app $out/Applications
    '';

    meta = with lib; {
      description = "Rancher Desktop";
      homepage = "https://www.resilio.com/";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.unfreeRedistributable;
      platforms = ["aarch64-darwin" "x86_64-darwin"];
      maintainers = with maintainers; [berryp];
    };
  }