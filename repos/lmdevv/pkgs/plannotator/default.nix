{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.28.8";

  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "plannotator: unsupported OS ${stdenv.hostPlatform.system}";

  arch =
    if lib.hasPrefix "x86_64" stdenv.hostPlatform.system then
      "x64"
    else if
      lib.hasPrefix "aarch64" stdenv.hostPlatform.system
      || lib.hasPrefix "arm64" stdenv.hostPlatform.system
    then
      "arm64"
    else
      throw "plannotator: unsupported arch ${stdenv.hostPlatform.system}";

  sha256BySystem = {
    "x86_64-linux" = "sha256-7uLtpL84VEbjP5VOetY0G7yZ58ZxdnsQE4L1iza6vbE=";
    "aarch64-linux" = "sha256-Emgr2IeZqBQ2FR3umHsrek6PN/2C9HWaHfOd6UGuHeU=";
    "x86_64-darwin" = "sha256-Ycgt+Adgt6Tbjndb5sYIFzuvjSfrixSolJRBSairYhc=";
    "aarch64-darwin" = "sha256-YS4jHMrBx1+in5/Zbg89aB3PDbOAQukpWAjtcrHTMog=";
  };

  srcUrl = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-${os}-${arch}";
  srcHash =
    sha256BySystem.${stdenv.hostPlatform.system}
      or (throw "plannotator: missing sha256 for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "plannotator";
  inherit version;

  src = fetchurl {
    url = srcUrl;
    sha256 = srcHash;
  };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp "$src" "$out/bin/plannotator"
    chmod +x "$out/bin/plannotator"

    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "Annotate and review coding agent plans and code diffs visually";
    longDescription = ''
      Plannotator lets you annotate and review coding agent plans and
      code diffs visually, share with your team, and send feedback to
      agents with one click.
    '';
    homepage = "https://plannotator.ai";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "plannotator";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}