{
  lib,
  rustPlatform,
  fetchFromGitHub,
  libffi,
  libxml2,
  ncurses,
  zlib,
  llvmPackages_17,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "inko";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jVfAfR02R2RaTtzFSBoLuq/wdPaaI/eochrZaRVdmHY=";
  };

  cargoHash = "sha256-IOMhwcZHB5jVYDM65zifxCjVHWl1EBbxNA3WVmarWcs=";

  buildInputs = [
    libffi
    libxml2
    ncurses
    zlib
  ];

  strictDeps = true;

  env.LLVM_SYS_170_PREFIX = llvmPackages_17.llvm.dev;

  # Some of the tests require git to be installed.
  doCheck = false;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "inko";
    description = "A language for building concurrent software with confidence";
    homepage = "https://github.com/inko-lang/inko";
    changelog = "https://github.com/inko-lang/inko/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
