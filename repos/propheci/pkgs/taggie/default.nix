{
  fenix,
  fetchFromGitHub,
  kdePackages,
  makeRustPlatform,
  pkg-config,
  nix-filter,
}: let
  pkgName = "taggie";
  pkgVersion = "0.1.0";
  pkgSrc = nix-filter {
    name = pkgName;
    root = fetchFromGitHub {
      owner = "ravicious";
      repo = "taggie";
      rev = "v${pkgVersion}";
      hash = "sha256-XPfy/vt+9EISXolDEvZY0q+F9DkuCkDRLQD+QaO60fg=";
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
    buildInputs = [kdePackages.taglib];

    PKG_CONFIG_PATH = "${kdePackages.taglib}/lib/pkgconfig";

    src = pkgSrc;
    cargoLock = {
      lockFile = "${pkgSrc}/Cargo.lock";
      # outputHashes = {
      #   "symphonia-0.5.4" = "sha256-lcJ6T9w5ZM+HzJ7HjKllgyzhJaRdQ0EkgLBgja442K0=";
      # };
    };

    meta = {
      description = "Edit audio tags in Vim/Emacs/VS Code/your favorite text editor";
      homepage = "https://github.com/ravicious/taggie";
      mainProgram = pkgName;
    };
  }

