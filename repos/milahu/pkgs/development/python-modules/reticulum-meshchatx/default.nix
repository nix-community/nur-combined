{
  lib,
  stdenv,
  fetchFromGitea,
  buildNpmPackage,
  electron,
  python,
  buildPythonApplication,
  setuptools,
  nodejs,
  pnpmConfigHook,
  pnpm,
  fetchPnpmDeps,
  npmHooks,
  # jq, # python3.pkgs.jq
  pkgs,
  websockets,
  aiohttp,
  peewee,
  lxmfy,
  psutil,
  bcrypt,
  aiohttp-session,
  pycparser, # >=3.0 not satisfied by version 2.23
  requests,
  audioop-lts,
  ply,
  lxst,
  jaraco-context,
  espeak,
  ffmpeg,
  copyDesktopItems,
  makeDesktopItem,
  imagemagick,
}:

stdenv.mkDerivation (finalAttrs: {

  pname = "reticulum-meshchatx";

  desktopName = "Reticulum MeshChatX";

  version = "4.2.1-21db104";

  src = fetchFromGitea {
    domain = "git.quad4.io";
    owner = "RNS-Things";
    repo = "MeshChatX";
    rev = "21db1046af08161173290ea42a9dfcda7b58a370";
    hash = "sha256-p9KCpVEvilFyhSZsds+ZaLG4AvGnX9IueN+E9vNKVvE=";
  };

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  #   function npm() { pnpm "$@"; }

  postPatch = ''
    substituteInPlace electron/main.js \
      --replace-fail \
        'const possiblePaths = [' \
        'const possiblePaths = ["${finalAttrs.reticulum-meshchatx-backend}/bin/.reticulum-meshchatx-backend",' \
      --replace-fail \
        '        ]);' \
        '        ], { env: { ...process.env, "RETICULUM_MESHCHATX_FRONTEND_DIR": "'$out'/lib/node_modules/reticulum-meshchatx" } });'
  '';

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    nodejs
    pnpmConfigHook
    pnpm
    npmHooks.npmBuildHook
    npmHooks.npmInstallHook
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-tGhOG/4KN83x75AIaAJoNwaUs+UH+F+2KAxIhNB9BVY=";
  };

  npmBuildScript = "build-frontend";

  desktopItems = [
    (makeDesktopItem {
      type = "Application";
      name = finalAttrs.pname;
      desktopName = finalAttrs.desktopName;
      comment = finalAttrs.meta.description;
      exec = finalAttrs.meta.mainProgram;
      icon = finalAttrs.pname;
      categories = [ "Chat" ];
    })
  ];

  # no. this breaks fetchPnpmDeps
  # dontNpmPrune = true;

  # dont run "npm prune" in installPhase (npmHooks.npmInstallHook)
  preInstall = ''
    dontNpmPrune=1
  '';

  # npmInstallFlags = "--verbose";
  # npmPruneFlags = "--verbose --offline";
  # npmPackFlags = "--verbose";

  postInstall = ''
    mkdir $out/bin
    cat >$out/bin/reticulum-meshchatx <<EOF
    #!/bin/sh
    export NODE_PATH=$out/lib/node_modules/reticulum-meshchatx/node_modules
    exec ${electron}/bin/electron $out/lib/node_modules/reticulum-meshchatx/electron/main.js "\$@"
    EOF
    chmod +x $out/bin/reticulum-meshchatx

    cp -r meshchatx/public/ $out/lib/node_modules/reticulum-meshchatx

    for i in 16 24 48 64 96 128 256 512; do
      mkdir -p $out/share/icons/hicolor/$i"x"$i/apps
      magick logo/logo.png -background none -resize $i"x"$i $out/share/icons/hicolor/$i"x"$i/apps/${finalAttrs.pname}.png
    done
  '';

  meta = {
    description = "A Reticulum MeshChat fork from the future";
    homepage = "https://git.quad4.io/RNS-Things/MeshChatX";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "reticulum-meshchatx";
  };

  passthru = {
    inherit (finalAttrs) reticulum-meshchatx-backend;
  };

  reticulum-meshchatx-backend = buildPythonApplication {

    pname = "${finalAttrs.pname}-backend";

    inherit (finalAttrs) version src meta;

    pyproject = true;

    build-system = [ setuptools ];

    postPatch = ''
      sed -i -E 's/([a-z0-9])(==|>=)[0-9.]+(,<[0-9.]+)?"/\1"/; s/"(=|==|>=|\^)[0-9.]+(,<[0-9.]+)?"/"*"/' requirements.txt pyproject.toml
      substituteInPlace pyproject.toml \
        --replace-fail \
          'requires-python = "*"' \
          'requires-python = ">=3.11"' \
        --replace-fail \
          'meshchat = "meshchatx.meshchat:main"' \
          '".reticulum-meshchatx-backend" = "meshchatx.meshchat:main"'

      # dont use cx_Freeze
      # fix: ValueError: Egg metadata expected ... but not found
      substituteInPlace pyproject.toml \
        --replace-fail "cx-freeze =" "# cx-freeze ="

      substituteInPlace meshchatx/meshchat.py \
        --replace-fail \
          'public_dir = self.get_public_path()' \
          'public_dir = os.environ["RETICULUM_MESHCHATX_FRONTEND_DIR"] + "/public"' \
        --replace-fail \
          'def get_file_path(filename):' \
          "$(
            echo 'def get_file_path(filename):'
            echo '    # print(f"get_file_path: filename = {filename}")'
            echo '    return os.environ["RETICULUM_MESHCHATX_FRONTEND_DIR"] + "/" + filename'
          )"

      substituteInPlace meshchatx/src/backend/voicemail_manager.py \
        --replace-fail \
          'self.espeak_path = self._find_espeak()' \
          'self.espeak_path = "${espeak}/bin/espeak"' \
        --replace-fail \
          'self.ffmpeg_path = self._find_ffmpeg()' \
          'self.ffmpeg_path = "${ffmpeg}/bin/ffmpeg"'
    '';

    postInstall = ''
      cp package.json $out/${python.sitePackages}/meshchatx
    '';

    dependencies = [
      websockets
      aiohttp
      peewee
      lxmfy
      psutil
      bcrypt
      aiohttp-session
      pycparser # >=3.0 not satisfied by version 2.23
      requests
      audioop-lts
      ply
      lxst
      jaraco-context
    ];

  };

})
