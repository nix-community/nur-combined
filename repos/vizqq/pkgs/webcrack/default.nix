{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_9,
  makeBinaryWrapper,
  versionCheckHook,
  nodejs,
}:
let
  workspace = "webcrack";
  pnpm = pnpm_9;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "webcrack";
  version = "2.15.1";

  src = fetchFromGitHub {
    owner = "j4k0xb";
    repo = "webcrack";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-9xCndYtGXnVGV6gXdqjLM4ruSIHi7JRXPHRBom7K7Ds=";
  };

  pnpmWorkspaces = [ workspace ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    hash = "sha256-9dEapxq88DNujaZp7WE5Mw8xgxroRnhjb77U5EPK7Bg=";
  };

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    pnpm.configHook
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    pnpm --filter ${workspace} build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/webcrack}
    cp -r {packages,node_modules} $out/lib/webcrack

    makeWrapper ${lib.getExe nodejs} $out/bin/webcrack \
      --inherit-argv0 \
      --add-flags $out/lib/webcrack/packages/webcrack/dist/cli.js

    runHook postInstall
  '';

  meta = {
    description = "Deobfuscate obfuscator.io, unminify and unpack bundled javascript";
    homepage = "https://github.com/j4k0xb/webcrack";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "webcrack";
  };
})
