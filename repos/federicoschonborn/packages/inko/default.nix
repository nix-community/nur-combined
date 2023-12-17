{ lib
, rustPlatform
, fetchFromGitHub
, libffi
, libxml2
, ncurses
, zlib
, llvmPackages_15
, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "inko";
  version = "0.13.2";

  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    rev = "v${version}";
    hash = "sha256-nCnlN/jn08TQKwrCiIzertjx0wUNphdefteaD/3rQx8=";
  };

  cargoHash = "sha256-2abb7zM+nL5j+pPGl13DMJK1GH66UoXOcJu/lKOgfwc=";

  buildInputs = [
    libffi
    libxml2
    ncurses
    zlib
  ];

  env.LLVM_SYS_150_PREFIX = llvmPackages_15.llvm.dev;

  # Some of the test require git to be installed.
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
