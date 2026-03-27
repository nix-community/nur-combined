{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  unzip,
  installShellFiles,
}:

let
  version = "0.3.11";

  # Map platform to upstream's OS/ARCH path segments.
  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "coderabbit-cli: unsupported OS ${stdenv.hostPlatform.system}";

  arch =
    if lib.hasPrefix "x86_64" stdenv.hostPlatform.system then
      "x64"
    else if
      lib.hasPrefix "aarch64" stdenv.hostPlatform.system
      || lib.hasPrefix "arm64" stdenv.hostPlatform.system
    then
      "arm64"
    else
      throw "coderabbit-cli: unsupported arch ${stdenv.hostPlatform.system}";

  sha256BySystem = {
    "x86_64-linux" = "sha256-J69gcDX65YTYdmPidDgXlEGDRl17zIp6dTr/LNl0FCg=";
    "aarch64-linux" = "sha256-V77KLrBR4OXuO8VmoF07xrrttRbC2NdpQHivf7E+o6k=";
    "x86_64-darwin" = "sha256-5jkX5/UJ7yWmUUuGFzrkpi8wGR3prNmvedyw9lCrpEU=";
    "aarch64-darwin" = "sha256-HCPtqC5Cg6ZONbmCY3KVGkhr2LgZc9Mn9zEOtroRLAE=";
  };

  srcUrl = "https://cli.coderabbit.ai/releases/${version}/coderabbit-${os}-${arch}.zip";
  srcHash =
    sha256BySystem.${stdenv.hostPlatform.system}
      or (throw "coderabbit-cli: missing sha256 for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "coderabbit-cli";
  inherit version;

  src = fetchurl {
    url = srcUrl;
    sha256 = srcHash;
  };

  # The zip contains the binary directly
  sourceRoot = ".";

  dontBuild = true;

  nativeBuildInputs =
    [ unzip installShellFiles ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
    ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"

    # Install the main binary
    install -Dm755 coderabbit "$out/bin/coderabbit"

    # Create 'cr' alias symlink
    ln -s "$out/bin/coderabbit" "$out/bin/cr"

    runHook postInstall
  '';

  # No tests provided upstream
  doCheck = false;

  meta = with lib; {
    description = "CodeRabbit CLI - AI-powered code review tool";
    longDescription = ''
      The CodeRabbit CLI is a command-line interface for CodeRabbit,
      an AI-powered code review tool. It provides a way to get code
      reviews and suggestions directly from your terminal.
    '';
    homepage = "https://coderabbit.ai";
    license = licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "coderabbit";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
