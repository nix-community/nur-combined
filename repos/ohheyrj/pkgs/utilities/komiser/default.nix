{ lib
, stdenvNoCC
, fetchurl
, makeWrapper
, config
, generatedDarwinArm64
, generatedDarwinX86
, generatedLinuxX86
}:

let
  platform = stdenvNoCC.hostPlatform.system;
  generated =
    if platform == "aarch64-darwin" then generatedDarwinArm64
    else if platform == "x86_64-darwin" then generatedDarwinX86
    else if platform == "x86_64-linux" then generatedLinuxX86
    else throw "Unsupported platform: ${platform}";
in

stdenvNoCC.mkDerivation {
  inherit (generated) pname version src;
  sourceRoot = ".";
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 $src $out/bin/komiser
  '';

  meta = with lib; {
    description = "Cloud cost visibility and optimisation tool";
    homepage = "https://github.com/tailwarden/komiser";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    broken = !(config.allowUnfree or false);
  };
}
