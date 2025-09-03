{ pkgs, ... }:

rec {
  cargoCratesIoRegistryGit = pkgs.fetchgit {
    url = "https://github.com/rust-lang/crates.io-index";
    rev = "6e9be72216a51bf674a572b050082beca073a5cf";
    hash = "sha256-hpfJBtN6qMW9m4C7fQ+w3pEfgoLPedFJ4J84wzKPkhI=";
  };

  cargoConfigWithLocalRegistry =
    let
      linkfarm = pkgs.linkFarm "crates.io-index" [
        {
          name = "index";
          path = cargoCratesIoRegistryGit;
        }
      ];
    in
    pkgs.writeTextFile {
      name = "cargo_config";
      destination = "/config.toml";
      text = ''
        [source]
        [source.crates-io]
        replace-with = "local-copy"
        [source.local-copy]
        local-registry = "${linkfarm}"
      '';
    };

  mkCargoLock =
    { file }:
    pkgs.runCommandLocal "Cargo.lock"
      {
        inherit file;
        nativeBuildInputs = [ pkgs.cargo ];
        CARGO_HOME = cargoConfigWithLocalRegistry;
      }
      ''
        mkdir src
        ln -s "$file" Cargo.toml
        touch src/main.rs
        cargo generate-lockfile
        cp Cargo.lock $out
      '';

  mkCargoDoc =
    {
      name,
      version ? "*",
    }:

    pkgs.stdenv.mkDerivation (finalAttrs: {
      name = "cargo-doc-${name}";

      src = pkgs.emptyDirectory;

      nativeBuildInputs = [
        pkgs.rustPlatform.cargoSetupHook
        pkgs.rustc
        pkgs.cargo
      ];

      cargotoml = pkgs.writeText "Cargo.toml" ''
        [package]
        name = "nix-build"
        version = "0.0.1"
        edition = "2024"
        [dependencies]
        ${name} = "${version}"
      '';

      buildPhase = ''
        runHook preBuild

        ln -s $cargotoml Cargo.toml
        mkdir src
        touch src/main.rs
        cargo doc --no-deps --package "${name}" --offline

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mv target/doc $out

        runHook postInstall
      '';

      cargoDeps = pkgs.rustPlatform.importCargoLock {
        lockFile = mkCargoLock { file = finalAttrs.cargotoml; };
      };

      postPatch = ''
        ln -s $cargoDeps/Cargo.lock
      '';
    });
}
