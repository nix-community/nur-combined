{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildFHSEnv,
  writeShellScript,
  buildNpmPackage,
  nodejs,
  makeWrapper,
  enabledPlugins ? [
    "bst"
    "ddr"
    "gitadora"
    "iidx"
    "jubeat"
    "mga"
    "museca"
    "nostalgia"
    "popn"
    "popn-hello"
    "sdvx"
  ],
}:

let
  pname = "asphyxia";
  version = "v1.60b";

  meta = with lib; {
    description = "This is a “e-amuse emulator”";
    homepage = "https://asphyxia-core.github.io/";
    license = licenses.gpl3Only;
    mainProgram = pname;
  };

  coreSrc = fetchFromGitHub {
    owner = "asphyxia-core";
    repo = "core";
    rev = version;
    sha256 = "sha256-bRgMLvyPF5fIr2NaruwB+oY2ItZ7Ulo0muFj9BH3j38=";
  };

  pluginSrc = fetchFromGitHub {
    owner = "asphyxia-core";
    repo = "plugins";
    # tracing "stable" branch
    rev = "997d141b3ba2ca7eb6806490ab2926cce48863c5";
    sha256 = "sha256-xxhnwIC8Ik0Wq3ccKtxXvYXSNfx5zoianoFDOGfGo1c=";
  };

  core = buildNpmPackage rec {
    inherit version meta;

    pname = "asphyxia-core";

    src = coreSrc;

    npmDepsHash = "sha256-/wFg4fZL2CBO/XKHbsat28Bk1IzlPtFta2sJlShw89U=";

    nativeBuildInputs = [ makeWrapper ];

    postPatch = ''
      substituteInPlace src/utils/EamuseIO.ts \
        --replace-fail \
        "export const ASSETS_PATH = path.join(pkg ? __dirname : \`../build-env\`, 'assets');" \
        "export const ASSETS_PATH = '$out/share/asphyxia/assets';"

      substituteInPlace src/utils/EamuseIO.ts \
        --replace-fail \
        "export const PLUGIN_PATH = path.join(EXEC_PATH, 'plugins');" \
        "export const PLUGIN_PATH = process.env.ASPHYXIA_PLUGIN_PATH;"
    '';

    dontNpmBuild = true;

    buildPhase = ''
      runHook preBuild

      npx --no-install tsc

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/asphyxia
      mkdir -p $out/share/asphyxia

      cp -r dist package.json node_modules plugins $out/lib/asphyxia/
      cp -r build-env/assets $out/share/asphyxia/

      makeWrapper ${nodejs}/bin/node $out/bin/asphyxia \
        --add-flags "$out/lib/asphyxia/dist/AsphyxiaCore.js"

      runHook postInstall
    '';
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version meta;

  src = pluginSrc;

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/asphyxia/plugins/

    cp ${coreSrc}/plugins/asphyxia-core.d.ts $out/lib/asphyxia/plugins/
    cp ${coreSrc}/plugins/package.json $out/lib/asphyxia/plugins/
    cp ${coreSrc}/plugins/tsconfig.json $out/lib/asphyxia/plugins/

    ${lib.concatMapStringsSep "\n" (
      p: "cp -r $src/${p}@asphyxia $out/lib/asphyxia/plugins/"
    ) enabledPlugins}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    makeWrapper ${core}/bin/asphyxia $out/bin/asphyxia \
      --set-default ASPHYXIA_PLUGIN_PATH $out/lib/asphyxia/plugins/

    runHook postInstall
  '';
}
