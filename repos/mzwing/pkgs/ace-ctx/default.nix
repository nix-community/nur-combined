{
  lib,
  stdenv,
  rustPlatform,
  craneLib ? null,
  source,
  makeWrapper,
  xdg-utils,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

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
in
  if craneLib == null
  then
    # Fallback for consumers without crane (e.g. importing this repository's
    # default.nix with plain nixpkgs): a regular single-layer build.
    rustPlatform.buildRustPackage {
      inherit
        pname
        src
        version
        nativeBuildInputs
        postInstall
        postFixup
        installCheckPhase
        meta
        ;

      cargoHash = "sha256-Cu1tvGpqxzz4J8x80pd+MpAUZkn7NbByjFXVM3L5S8E=";

      cargoBuildFlags = [
        "--package"
        "ace-ctx"
      ];
      cargoTestFlags = ["--all-features"];
      doCheck = true;

      doInstallCheck = true;
    }
  else let
    commonArgs = {
      inherit pname src;
      cargoExtraArgs = "--package ace-ctx";
    };
    # Dependencies only. The version is deliberately constant so this layer
    # is rebuilt only when Cargo.lock or the toolchain changes, never on an
    # upstream version bump.
    cargoArtifacts = craneLib.buildDepsOnly (commonArgs
      // {
        version = "0";
        doCheck = false;
      });
  in
    craneLib.buildPackage (commonArgs
      // {
        inherit
          version
          cargoArtifacts
          nativeBuildInputs
          postInstall
          postFixup
          installCheckPhase
          meta
          ;
        cargoTestExtraArgs = "--all-features";
        doCheck = true;
        doInstallCheck = true;
      })
