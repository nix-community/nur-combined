{
  lib,
  stdenv,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kuroko";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "kuroko-lang";
    repo = "kuroko";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-+hzgRX0T0LhAcHHBdOp8Tlo2hO2gxt6wkHjulDHdZ1Q=";
  };

  nativeInstallCheckInputs = [ versionCheckHook ];

  makeFlags = [ "prefix=${placeholder "out"}" ];

  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "kuroko";
    description = "Dialect of Python with explicit variable declaration and block scoping, with a lightweight and easy-to-embed bytecode compiler and interpreter";
    homepage = "https://github.com/kuroko-lang/kuroko";
    changelog = "https://github.com/kuroko-lang/kuroko/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
