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
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    rev = "v${version}";
    hash = "sha256-NptfVWXwbv09Lpq067nqXSO9wlcsS55zw4AxmrO5n80=";
  };

  cargoHash = "sha256-bhd0qJ0KGGdd428bSdw4VCcMN8bZTOnHYSVbgQzgkBs=";

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
