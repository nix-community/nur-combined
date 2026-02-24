{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
  cargoCratesIoRegistryGit = pkgs.fetchFromGitHub {
    owner = "rust-lang";
    repo = "crates.io-index";
    rev = "0b99b088c9dcd4e797a2bdc47a3a2ef7d1f19403";
    hash = "sha256-9qhYz6D8da/0zaBfhR08NtSVOEuXYfnvpovdfrFWvfM=";
  };

  cargoConfigWithLocalRegistry = pkgs.linkFarm "cargo-home" {
    "config.toml" = pkgs.writers.writeTOML "config.toml" {
      source.crates-io = {
        replace-with = "local-copy";
      };
      source.local-copy = {
        local-registry = pkgs.linkFarm "crates.io-index" {
          index = cargoCratesIoRegistryGit;
        };
      };
    };
  };

  mkCargoLock =
    { file }:
    pkgs.runCommandLocal "Cargo.lock"
      {
        nativeBuildInputs = [ pkgs.cargo ];
        env = {
          CARGO_HOME = cargoConfigWithLocalRegistry;
          FILE = file;
        };
      }
      ''
        mkdir src
        ln -s -- "$FILE" Cargo.toml
        touch src/main.rs
        cargo generate-lockfile
        cp -- Cargo.lock $out
      '';

  mkCargoDoc =
    {
      name,
      version ? "*",
      extraNativeBuildInputs ? [ ],
    }:

    pkgs.stdenv.mkDerivation (finalAttrs: {
      name = "cargo-doc-${name}";

      src = pkgs.emptyDirectory;

      nativeBuildInputs = [
        pkgs.rustPlatform.cargoSetupHook
        pkgs.rustc
        pkgs.cargo
        pkgs.pkg-config # used by a lot of native library bindings
      ]
      ++ extraNativeBuildInputs;

      env = {
        CARGO_NET_OFFLINE = "1";
        __CARGO_TOML = pkgs.writers.writeTOML "Cargo.toml" {
          package = {
            name = "nix-build";
            version = "0.0.1";
            edition = "2024";
          };
          dependencies.${name} = {
            inherit version;
          };
        };
      };

      buildPhase = ''
        runHook preBuild

        ln -s -- $__CARGO_TOML Cargo.toml
        mkdir src
        touch src/main.rs
        cargo doc --package "${name}"

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mv target/doc $out

        runHook postInstall
      '';

      cargoDeps = pkgs.rustPlatform.importCargoLock {
        lockFile = mkCargoLock { file = "${finalAttrs.env.__CARGO_TOML}"; };
      };

      postPatch = ''
        ln -s $cargoDeps/Cargo.lock
      '';

      preferLocalBuild = true;
      allowSubstitutes = false;
    });

  mkRustScriptCargoToml =
    { file }:
    pkgs.runCommandLocal "Cargo.toml"
      {
        nativeBuildInputs = [
          pkgs.rustc
          pkgs.cargo
          pkgs.rust-script
          pkgs.writableTmpDirAsHomeHook
        ];
      }
      ''
        cp -- "${file}" script.rs
        rust-script --pkg-path . -p script.rs
        sed -i -e 's,/build/script.rs,${file},' Cargo.toml
        cp -- Cargo.toml $out
      '';

  importRust = {
    check = lib.hasSuffix ".rs";
    __functor =
      _self: file:
      let
        tomlString = lib.pipe file [
          (it: mkRustScriptCargoToml { file = it; })
          lib.readFile
          lib.unsafeDiscardStringContext
        ];
        selfTOML = lib.fromTOML tomlString;
      in
      selfTOML
      //
        # To repair the string context.
        {
          bin = [
            {
              name = selfTOML.package.name;
              path = "${file}";
            }
          ];
        };
  };

}
