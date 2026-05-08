{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hashes;

  targets = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "darwin-x64";
    "aarch64-darwin" = "darwin-arm64";
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "hunk";
  inherit version;

  src = fetchurl {
    url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-${target}.tar.gz";
    hash =
      hashes.${stdenv.hostPlatform.system}
        or (throw "Missing hunk hash for system ${stdenv.hostPlatform.system}");
  };

  sourceRoot = "hunkdiff-${target}";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  # Bun standalone executables contain the JS bundle in the binary. Stripping leaves
  # a runnable Bun runtime, but loses the Hunk entrypoint. Very funny, thanks.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -D -m755 hunk $out/bin/hunk
    install -D -m644 metadata.json $out/share/hunk/metadata.json

    runHook postInstall
  '';

  meta = with lib; {
    description = "Review-first terminal diff viewer for agent-authored changesets";
    homepage = "https://github.com/modem-dev/hunk";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = [ ];
    mainProgram = "hunk";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
