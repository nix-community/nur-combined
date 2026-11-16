{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  pname = "plannotator";
  sources = lib.importJSON ./sources.json;

  platforms = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x64";
    aarch64-darwin = "darwin-arm64";
  };

  platform =
    platforms.${stdenv.hostPlatform.system}
      or (throw "${pname}: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  inherit pname;
  inherit (sources) version;

  src = fetchurl {
    url = "https://github.com/backnotprop/plannotator/releases/download/v${sources.version}/plannotator-${platform}";
    sha256 = sources.hashes.${platform};
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Bun single-file executables carry the JS bundle after the ELF/Mach-O
  # payload; stripping truncates it.
  dontStrip = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/plannotator
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME=$(mktemp -d)
    $out/bin/plannotator --version | grep -F "${sources.version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Interactive plan and code review tool for AI coding agents";
    homepage = "https://github.com/backnotprop/plannotator";
    changelog = "https://github.com/backnotprop/plannotator/releases/tag/v${sources.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames platforms;
    mainProgram = "plannotator";
  };
}
