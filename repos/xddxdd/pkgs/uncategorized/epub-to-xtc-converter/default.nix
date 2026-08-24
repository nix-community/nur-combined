{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
  nix-update-script,
  nodejs,
  versionCheckHook,
}:
buildNpmPackage (finalAttrs: {
  pname = "epub-to-xtc-converter";
  version = "0.8.0";
  src = fetchFromGitHub {
    owner = "bigbag";
    repo = "epub-to-xtc-converter";
    tag = "v0.8.0";
    hash = "sha256-ox921Uk0YaKmCRL66ksbKj7YnCC0i1E3BMEChyZpS4U=";
  };
  sourceRoot = "${finalAttrs.src.name}/cli";
  npmDepsHash = "sha256-GuvoKLhcFqEw8zfMBl4vc4ISp1/r+FOQOpxMLOXrPXs=";

  postPatch = ''
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"${finalAttrs.version}\"/" package.json
    sed -i "s/\.version('1\.0\.0')/.version('${finalAttrs.version}')/" index.js
  '';

  dontNpmBuild = true;
  npmFlags = [ "--omit=dev" ];

  preBuild = ''
    npm rebuild sharp
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/epub-to-xtc-converter/cli $out/lib/epub-to-xtc-converter/web
    cp -r *.js *.json node_modules $out/lib/epub-to-xtc-converter/cli/
    cp ${finalAttrs.src}/web/crengine.js ${finalAttrs.src}/web/crengine.wasm $out/lib/epub-to-xtc-converter/web/

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/epub-to-xtc \
      --add-flags "$out/lib/epub-to-xtc-converter/cli/index.js"

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };
  meta = {
    description = "CLI tool for converting EPUB files to XTC/XTCH format for Xteink e-readers";
    homepage = "https://github.com/bigbag/epub-to-xtc-converter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "epub-to-xtc";
    platforms = lib.platforms.linux;
  };
})
