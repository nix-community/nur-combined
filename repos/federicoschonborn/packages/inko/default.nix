{
  lib,
  rustPlatform,
  fetchFromGitHub,
  libffi,
  libxml2,
  ncurses,
  zlib,
  llvmPackages_15,
  nix-update-script,
}:
let
  version = "0.14.0";
  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    rev = "v${version}";
    hash = "sha256-6NnTqc9V/Ck4Dzo6ZcWLpCNQQVym55gQ3q7w+0DXiDc=";
  };
in
rustPlatform.buildRustPackage {
  pname = "inko";
  inherit version;

  inherit src;

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "inkwell-0.2.0" = "sha256-E1DpyNlmPmD455Gxtnl2OJ/nvr0nj+xhlFNAj3lEccA=";
    };
  };

  buildInputs = [
    libffi
    libxml2
    ncurses
    zlib
  ];

  env.LLVM_SYS_150_PREFIX = llvmPackages_15.llvm.dev;

  # Some of the tests require git to be installed.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "inko";
    description = "A language for building concurrent software with confidence";
    homepage = "https://github.com/inko-lang/inko";
    changelog = "https://github.com/inko-lang/inko/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
