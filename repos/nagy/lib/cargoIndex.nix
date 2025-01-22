{
  pkgs,
  lib ? pkgs.lib,
  ...
}:

rec {
  cargoEmptyHome =
    pkgs.runCommandLocal "cargo-home"
      {
        nativeBuildInputs = [
          pkgs.rustc
          pkgs.cargo
          pkgs.cacert
        ];
      }
      ''
        CARGO_HOME=$out
        cargo search --limit 0
      '';

  cargoCratesIoRegistryGit = pkgs.fetchgit {
    url = "https://github.com/rust-lang/crates.io-index";
    rev = "79d5c20daee3bf107616e0c802779bd66b80a266";
    hash = "sha256-mngh0XvY5UBiEKGR9sqS1dddRhQ6RS8titPtGq0cNkY=";
  };

  cargoCratesIoRegistry = pkgs.linkFarm "crates.io-index" [
    {
      name = "index";
      path = cargoCratesIoRegistryGit;
    }
  ];

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

  mkCargoLock =
    { file }:
    pkgs.runCommandLocal "Cargo.lock"
      {
        inherit file;
        nativeBuildInputs = [ pkgs.cargo ];
      }
      ''
        mkdir src .cargo
        ln -s ${cargoConfigWithLocalRegistry}/.cargo/config.toml .cargo/
        ln -s $file Cargo.toml
        touch src/main.rs
        cargo generate-lockfile
        mv Cargo.lock $out
      '';

  mkRustScriptDir =
    {
      file,
      pname ? "main",
    }:
    pkgs.runCommandLocal "rust-script"
      {
        inherit file pname;
        nativeBuildInputs = [
          pkgs.rust-script
          pkgs.cargo
        ];
        CARGO_HOME = "/tmp/cargo";
      }
      ''
        mkdir /tmp/cargo $out
        ln -s ${cargoConfigWithLocalRegistry}/.cargo/config.toml /tmp/cargo/
        cp -v -- $file $pname.rs
        rust-script --cargo-output --package --pkg-path . $pname.rs
        sed -i Cargo.toml -e 's,^name = .*,name = "${pname}",g'
        sed -i Cargo.toml -e 's,^path = .*,path = "${pname}.rs",g'
        cargo generate-lockfile
        mv Cargo.* $pname.rs $out/
      '';

  mkRustScript =
    {
      file,
      name ? lib.removeSuffix ".rs" (builtins.baseNameOf file),
    }:
    pkgs.rustPlatform.buildRustPackage rec {
      inherit name;
      src = mkRustScriptDir {
        inherit file;
        pname = name;
      };
      lockFile = src + "/Cargo.lock";
      postPatch = ''
        cp $lockFile Cargo.lock
      '';
      cargoLock = { inherit lockFile; };
      doCheck = false; # dunno
    };

  mkCargoWatcher =
    {
      file,
      pname ? "main",
    }:
    pkgs.writeShellScriptBin "cargo-watcher" ''
      ln -fs ${mkRustScriptDir { inherit file pname; }}/Cargo.toml
      ln -fs ${mkRustScriptDir { inherit file pname; }}/Cargo.lock
      PATH=${pkgs.cargo-watch}/bin/:${pkgs.cargo}/bin/:${pkgs.gcc}/bin:$PATH \
        CARGO_TARGET_DIR=/tmp/cargotarget \
        ${pkgs.cargo}/bin/cargo watch "$@"
    '';
}
