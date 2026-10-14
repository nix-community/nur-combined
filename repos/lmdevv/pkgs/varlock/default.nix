{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "1.23.0";

  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "macos"
    else
      throw "varlock: unsupported OS ${stdenv.hostPlatform.system}";

  arch =
    if lib.hasPrefix "x86_64" stdenv.hostPlatform.system then
      "x64"
    else if
      lib.hasPrefix "aarch64" stdenv.hostPlatform.system
      || lib.hasPrefix "arm64" stdenv.hostPlatform.system
    then
      "arm64"
    else
      throw "varlock: unsupported arch ${stdenv.hostPlatform.system}";

  sha256BySystem = {
    "x86_64-linux" = "sha256-pA2Gzt3eLwMs2L3FlP7KdPYHVNAWFcGhEDHJ9MqX6O0=";
    "aarch64-linux" = "sha256-e1dLQgpq4CTzzGO5RNVYbuW96w5p5JRbw+EMaI0fJqQ=";
    "x86_64-darwin" = "sha256-dAzG44llPB0v0eWg8ASPUoO9IEJTkh9Ilg/J6W80hyo=";
    "aarch64-darwin" = "sha256-fRTa6510myQ1UoCVSpwbcIdTOFUpazrETfbEa6fVgrw=";
  };

  srcUrl = "https://github.com/dmno-dev/varlock/releases/download/varlock@${version}/varlock-${os}-${arch}.tar.gz";
  srcHash =
    sha256BySystem.${stdenv.hostPlatform.system}
      or (throw "varlock: missing sha256 for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "varlock";
  inherit version;

  src = fetchurl {
    url = srcUrl;
    sha256 = srcHash;
  };

  sourceRoot = ".";

  dontBuild = true;
  dontStrip = true;
  dontFixup = stdenv.hostPlatform.isDarwin;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/libexec"
    install -Dm755 varlock "$out/bin/varlock"

    if [ -f varlock-local-encrypt ]; then
      install -Dm755 varlock-local-encrypt "$out/libexec/varlock-local-encrypt"
    fi

    if [ -d VarlockEnclave.app ]; then
      cp -R VarlockEnclave.app "$out/libexec/VarlockEnclave.app"
    fi

    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "AI-safe .env files with schemas, validation, and secret redaction";
    longDescription = ''
      Varlock is a CLI for AI-safe .env files. A .env.schema declares and
      validates environment variables, secrets stay encrypted or loaded from
      external providers, and redaction plus a credential proxy keep secret
      values away from logs, terminals, and AI agents.
    '';
    homepage = "https://varlock.dev";
    changelog = "https://github.com/dmno-dev/varlock/releases/tag/varlock@${version}";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "varlock";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
