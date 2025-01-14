{
  lib,
  rustPlatform,
  rustc,
  fetchFromGitHub,
  libffi,
  libxml2,
  ncurses,
  zlib,
  llvmPackages_17,
  versionCheckHook,
  nix-update-script,
}:

let
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    rev = "refs/tags/v${version}";
    hash = "sha256-EKSjdoGZub23WmFDryY737j0d1rK+zlNupf+biD1o5o=";
  };
in

rustPlatform.buildRustPackage {
  pname = "inko";
  inherit version;

  inherit src;

  cargoLock.lockFile = ./Cargo.lock;

  buildInputs = [
    libffi
    libxml2
    ncurses
    zlib
  ];

  env.LLVM_SYS_170_PREFIX = llvmPackages_17.llvm.dev;

  # Some of the tests require git to be installed.
  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "inko";
    description = "A language for building concurrent software with confidence";
    homepage = "https://github.com/inko-lang/inko";
    changelog = "https://github.com/inko-lang/inko/releases/tag/v${version}";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
    broken = lib.versionOlder rustc.version "1.78.0";
  };
}
