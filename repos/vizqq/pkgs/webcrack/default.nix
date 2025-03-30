{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_9,
  makeBinaryWrapper,
  versionCheckHook,
  nodejs,
  node-gyp,
  python3,
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
  versionCheckProgramArg = [ "--version" ];
  doInstallCheck = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    pnpm.configHook
    nodejs
    node-gyp
    python3
  ];

  buildPhase = ''
    runHook preBuild

    pushd packages/webcrack/node_modules/isolated-vm
    node-gyp rebuild
    popd

    pnpm --filter ${workspace} build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    cp -r {packages,node_modules} $out/lib

    rm -r $out/lib/packages/config-*
    rm -r $out/lib/packages/webcrack/{src,test}
    rm $out/lib/packages/webcrack/{tsconfig.*,esbuild.config.js,eslint.config.js,.gitignore}
    find $out/lib/packages/webcrack -name '*.ts' -delete

    makeWrapper ${lib.getExe nodejs} $out/bin/webcrack \
      --inherit-argv0 \
      --add-flags $out/lib/packages/webcrack/dist/cli.js

    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "Deobfuscate obfuscator.io, unminify and unpack bundled javascript";
    homepage = "https://github.com/j4k0xb/webcrack";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "webcrack";
  };
})
