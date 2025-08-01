{ pkgs, ... }:

rec {
  cargoCratesIoRegistryGit = pkgs.fetchgit {
    url = "https://github.com/rust-lang/crates.io-index";
    rev = "0c42b451acc49c280588f01dd599af738f485664";
    hash = "sha256-eedG6VoOzcsRVvoLfGrTD8vDjseOxouw56iKUY2FDNk=";
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
