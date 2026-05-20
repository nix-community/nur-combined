{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.19.20";

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
    "x86_64-linux" = "sha256-KM8VxQLaROkQgqup2a0zAs17NoLOo7fPHwiEVtkP2S8=";
    "aarch64-linux" = "sha256-KpPE/P+HnsgNvpSRgyNnBTEB70Cf4I2Uiyl0Kycwx8k=";
    "x86_64-darwin" = "sha256-lLz3RYRTw0h7Bqtk3lJL+mdSxAMO0SVkWIWIOAw7yEY=";
    "aarch64-darwin" = "sha256-22+aGXQgAMStflRfo3kj12lyrzPaL2QqHoqeSCkl6Go=";
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