{ pkgs, lib }:

rec {

  cargoEmptyHome = pkgs.runCommandLocal "cargo-home" {
    nativeBuildInputs = [ pkgs.rustc pkgs.cargo pkgs.cacert ];
  } ''
    CARGO_HOME=$out
    cargo search --limit 0
  '';

  cargoCratesIoRegistryGit = pkgs.fetchgit {
    url = "https://github.com/rust-lang/crates.io-index";
    rev = "7999b6f424a56b0bc37fec2bbb2a439a0cb07961";
    sha256 = "sha256-akz1dPwvhFNaFa0JuKqvl8Mby9B5NFE64nVZSDTKCRc=";
  };

  cargoCratesIoRegistry = pkgs.linkFarm "crates.io-index" [{
    name = "index";
    path = cargoCratesIoRegistryGit;
  }];

  cargoConfigWithLocalRegistry = pkgs.writeTextFile {
    name = "cargo_config";
    destination = "/.cargo/config.toml";
    text = ''
      [source]
      [source.crates-io]
      replace-with = "local-copy"
      [source.local-copy]
      local-registry = "${cargoCratesIoRegistry}"
    '';
  };

  mkCargoLock = { file }:
    pkgs.runCommandLocal "Cargo.lock" {
      inherit file;
      nativeBuildInputs = [ pkgs.cargo ];
    } ''
      mkdir src .cargo
      ln -s ${cargoConfigWithLocalRegistry}/.cargo/config.toml .cargo/
      ln -s $file Cargo.toml
      touch src/main.rs
      cargo generate-lockfile
      mv Cargo.lock $out
    '';

  mkRustScriptDir = { file }:
    pkgs.runCommandLocal "rust-script" {
      inherit file;
      nativeBuildInputs = [ pkgs.rust-script pkgs.cargo ];
      CARGO_HOME = "/tmp/cargo";
    } ''
      mkdir /tmp/cargo $out
      ln -s ${cargoConfigWithLocalRegistry}/.cargo/config.toml /tmp/cargo/
      cp -v -- $file main.rs
      rust-script --cargo-output --gen-pkg-only --pkg-path . main.rs
      cargo generate-lockfile
      mv Cargo.* main.rs $out/
    '';

  mkRustScript = { file, pname ? "main", version ? "0.0.1" }:
    pkgs.rustPlatform.buildRustPackage rec {
      inherit pname version;
      src = mkRustScriptDir { inherit file; };
      lockFile = "${src}/Cargo.lock";
      postPatch = ''
        cp $lockFile Cargo.lock
      '';
      postInstall = ''
        mv $out/bin/* $out/bin/$pname
      '';
      cargoLock = { inherit lockFile; };
      doCheck = false; # dunno
    };
}
