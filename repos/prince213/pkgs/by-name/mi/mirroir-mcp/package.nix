{
  lib,
  fetchFromGitHub,
  stdenv,

  # nativeBuildInputs
  swift,
  swiftpm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mirroir-mcp";
  version = "0.40.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "jfarcand";
    repo = "mirroir-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C82BGpnahypcp6tmvMBVt63dQtQ9ppfyddLOW9klADI=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  postPatch = ''
    substituteInPlace Sources/mirroir-mcp/mirroir_mcp.swift \
      --replace-fail \
        'version: \(GitVersion.commitHash)' \
        'version: \(MirroirVersion.current)'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 -t $out/bin .build/${stdenv.hostPlatform.darwinArch}-apple-macosx/release/mirroir-mcp

    runHook postInstall
  '';

  meta = {
    description = "MCP server for controlling a real iPhone via macOS iPhone Mirroring";
    homepage = "https://mirroir.dev/";
    downloadPage = "https://github.com/jfarcand/mirroir-mcp/releases";
    changelog = "https://github.com/jfarcand/mirroir-mcp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "mirroir-mcp";
    platforms = lib.platforms.darwin;
  };
})
