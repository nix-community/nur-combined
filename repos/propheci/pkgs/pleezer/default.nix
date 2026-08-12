{
  alsa-lib,
  fenix,
  fetchFromGitHub,
  makeRustPlatform,
  pkg-config,
  nix-filter,
}: let
  pkgName = "pleezer";
  pkgVersion = "0.9.1";
  pkgSrc = nix-filter {
    name = pkgName;
    root = fetchFromGitHub {
      owner = "roderickvd";
      repo = "pleezer";
      rev = "v${pkgVersion}";
      hash = "sha256-k44aieajGKJ0Mn/pPigOKsJJ0PA7rWwek0SkW8aWrvI=";
    };
    include = [
      "Cargo.toml"
      "Cargo.lock"
      "build.rs"
      "src"
    ];
  };

  rustToolchain = fenix.stable.toolchain;
in
  (makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  })
  .buildRustPackage {
    name = pkgName;
    version = pkgVersion;

    nativeBuildInputs = [pkg-config];
    buildInputs = [alsa-lib];

    PKG_CONFIG_PATH = "${alsa-lib}/lib/pkgconfig";

    src = pkgSrc;
    cargoLock = {
      lockFile = "${pkgSrc}/Cargo.lock";
      outputHashes = {
        "symphonia-0.5.4" = "sha256-lcJ6T9w5ZM+HzJ7HjKllgyzhJaRdQ0EkgLBgja442K0=";
      };
    };

    meta = {
      description = "Headless Deezer Connect player 💜";
      homepage = "https://github.com/roderickvd/pleezer";
      mainProgram = pkgName;
    };
  }
