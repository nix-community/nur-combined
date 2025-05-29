{ lib
, stdenvNoCC
, fetchurl
, makeWrapper
, config
, generatedDarwinArm64
, generatedDarwinX86
, unzip
}:

let
  platform = stdenvNoCC.hostPlatform.system;
  generated =
    if platform == "aarch64-darwin" then generatedDarwinArm64
    else if platform == "x86_64-darwin" then generatedDarwinX86
    else throw "Unsupported platform: ${platform}";

  archSuffix = 
      if platform == "aarch64-darwin" then "arm64"
      else if platform == "x86_64-darwin" then "amd64"
      else throw "Unsupported platform: ${platform}";
in

stdenvNoCC.mkDerivation {
  pname = "gitkraken-cli";
  inherit (generated) version src;

  nativeBuildInputs = [ unzip ];

  sourceRoot = "gk_${generated.version}_darwin_${archSuffix}";

  installPhase = ''
    runHook preInstall
    
    # Debug: see what's in the current directory
    echo "Contents of source directory:"
    ls -la
    
    mkdir -p $out/bin
    # Install the actual binary, not $src
    cp gk $out/bin/gk
    chmod +x $out/bin/gk
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "GitKraken CLI is the developer tool that transforms how you interact with Git.";
    homepage = "https://www.gitkraken.com/cli";
    changelog = "https://github.com/gitkraken/gk-cli/releases";
    license = licenses.unfree;
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    broken = !(config.allowUnfree or false);
  };
}
