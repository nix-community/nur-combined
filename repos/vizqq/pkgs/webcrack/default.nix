{
  lib,
  stdenv,
  source,
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

  inherit (source) pname src;

  version = lib.replaceStrings [ "v" ] [ "" ] source.version;

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

  preInstall = ''
    rm node_modules/.modules.yaml
    rm -r node_modules/.bin
    rm -r packages/webcrack/node_modules/.bin
    rm -rf node_modules/.pnpm/{typescript*,prettier*}

    pnpm --ignore-scripts prune --prod

    find node_modules packages/webcrack/node_modules -xtype l -delete
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/packages/webcrack}
    cp -r packages/webcrack/{dist,package.json,node_modules} $out/lib/packages/webcrack
    cp -r node_modules $out/lib

    makeWrapper ${lib.getExe nodejs} $out/bin/webcrack \
     --add-flags $out/lib/packages/webcrack/dist/cli.js

    runHook postInstall
  '';

  # fix ERROR: noBrokenSymlinks
  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "Deobfuscate obfuscator.io, unminify and unpack bundled javascript";
    homepage = "https://github.com/j4k0xb/webcrack";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "webcrack";
  };
})
