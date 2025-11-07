{
  lib,
  stdenvNoCC,
  fetchurl,
  callPackage,
  pkgs,
  unzip,
}:
let
  # 首先构建 jar 文件的 derivation
  jarDerivation = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "lr2oraja";
    version = "build11611350155";

    nativeBuildInputs = [
      unzip
    ];

    src = fetchurl {
      url = "https://github.com/wcko87/lr2oraja/releases/download/${finalAttrs.version}/LR2oraja.zip";
      hash = "sha256-PNvk7KvXk3AD/HIc0utTr4jlKIH8SSBIBSbfbXC5kys=";
    };

    unpackPhase = ''
      unzip -qq -o $src
      mv beatoraja.jar ${finalAttrs.pname}.jar
    '';

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp ${finalAttrs.pname}.jar $out/${finalAttrs.pname}.jar

      runHook postInstall
    '';

    meta = with lib; {
      description = "lr2oraja - A beatoraja fork";
      homepage = "https://github.com/wcko87/lr2oraja";
      license = licenses.gpl3;
      maintainers = [ ];
      platforms = platforms.all;
    };
  });
in
pkgs.beatoraja.override {
  overrideDerivation = jarDerivation;
}
