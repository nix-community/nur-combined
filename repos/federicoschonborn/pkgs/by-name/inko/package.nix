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
  testers,
  inko,
# nix-update-script,
}:

let
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    rev = "v${version}";
    hash = "sha256-qsil2r0jVrh5WG7MOdQdAJMCY2gtEMYVAocvZBR53oM=";
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

  passthru = {
    tests.version = testers.testVersion { package = inko; };

    # updateScript = nix-update-script { };
  };

  meta = {
    mainProgram = "inko";
    description = "A language for building concurrent software with confidence";
    homepage = "https://github.com/inko-lang/inko";
    changelog = "https://github.com/inko-lang/inko/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder rustc.version "1.78.0";
  };
}
