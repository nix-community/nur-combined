{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.28.59";

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
    "x86_64-linux" = "sha256-3TV5srT9DRHKhM9xDViq3rh9dJVHL3Aruciachmva8U=";
    "aarch64-linux" = "sha256-uyo5UzyadxaZPJ9QKsxxaLPYgmIszZCRMANT4yVEtmY=";
    "x86_64-darwin" = "sha256-WmyNJTDyey7ZELSCtI8pl2InVAQ6GjdcgY6n23LMmo8=";
    "aarch64-darwin" = "sha256-iqvimjCMM3WYiZgDg/Camk6MElx++MI2+vXZ5SUWLwU=";
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