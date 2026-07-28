{
  lib,
  stdenv,
  rustPlatform,
  source,
  makeWrapper,
  xdg-utils,
}:
rustPlatform.buildRustPackage rec {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  cargoHash = "sha256-Cu1tvGpqxzz4J8x80pd+MpAUZkn7NbByjFXVM3L5S8E=";

  cargoBuildFlags = [
    "--package"
    "ace-ctx"
  ];
  cargoTestFlags = ["--all-features"];
  doCheck = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [makeWrapper];

  postInstall = ''
    install -Dm644 \
      LICENSE \
      LICENSE-COMMERCIAL \
      README.md \
      README-zh-CN.md \
      -t $out/share/doc/ace-ctx
    install -Dm644 docs/*.md -t $out/share/doc/ace-ctx/docs
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/ace-ctx \
      --prefix PATH : ${lib.makeBinPath [xdg-utils]}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/ace-ctx --version | grep -F '${version}'
    $out/bin/ace-ctx --help >/dev/null
    test -f $out/share/doc/ace-ctx/LICENSE
    test -f $out/share/doc/ace-ctx/LICENSE-COMMERCIAL

    runHook postInstallCheck
  '';

  meta = {
    description = "Rust implementation of a codebase context engine that enables AI assistants to search and understand codebases using natural language queries";
    homepage = "https://github.com/CodingOX/ace-ctx";
    changelog = "https://github.com/CodingOX/ace-ctx/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "ace-ctx";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
