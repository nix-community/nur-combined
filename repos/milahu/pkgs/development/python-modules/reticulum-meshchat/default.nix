{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  electron,
  python,
  buildPythonApplication,
  setuptools,
  aiohttp,
  lxmf,
  peewee,
  rns,
  websockets,
  copyDesktopItems,
  makeDesktopItem,
  imagemagick,
}:

buildNpmPackage (finalAttrs: {

  pname = "reticulum-meshchat";

  desktopName = "Reticulum MeshChat";

  version = "2.3.0-011876b";

  src = fetchFromGitHub {
    owner = "liamcottle";
    repo = "reticulum-meshchat";
    # tag = "v${version}";
    rev = "011876bec5e9233030af62ccc17225d9f9de3bc2";
    hash = "sha256-fydX3isqsUCMWX8PRdmk2b3G2164qTCBZsuYvww1X9c=";
  };

  npmDepsHash = "sha256-Q4xxqKd0SeWxK7oVHQ4uZmmy0xasNN/GvOiO10RSAC8=";

  npmBuildScript = "build-frontend";

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postPatch = ''
    substituteInPlace electron/main.js \
      --replace-fail \
        'var exe =' \
        'var exe = "${finalAttrs.reticulum-meshchat-backend}/bin/.reticulum-meshchat-backend"; //' \
      --replace-fail \
        ']);' \
        '], { env: { ...process.env, "RETICULUM_MESHCHAT_FRONTEND_PUBLIC_DIR": "'$out'/lib/node_modules/reticulum-meshchat/public" } });'
  '';

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
  ];

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

  postInstall = ''
    mkdir $out/bin
    cat >$out/bin/reticulum-meshchat <<EOF
    #!/bin/sh
    export NODE_PATH=$out/lib/node_modules/reticulum-meshchat/node_modules
    exec ${electron}/bin/electron $out/lib/node_modules/reticulum-meshchat/electron/main.js "\$@"
    EOF
    chmod +x $out/bin/reticulum-meshchat

    cp -r public $out/lib/node_modules/reticulum-meshchat

    for i in 16 24 48 64 96 128 256 512; do
      mkdir -p $out/share/icons/hicolor/$i"x"$i/apps
      magick logo/logo.png -background none -resize $i"x"$i $out/share/icons/hicolor/$i"x"$i/apps/${finalAttrs.pname}.png
    done
  '';

  meta = {
    description = "A simple mesh network communications app powered by the Reticulum Network Stack";
    homepage = "https://github.com/liamcottle/reticulum-meshchat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "reticulum-meshchat";
  };

  passthru = {
    inherit (finalAttrs) reticulum-meshchat-backend;
  };

  reticulum-meshchat-backend = buildPythonApplication {

    pname = "${finalAttrs.pname}-backend";

    inherit (finalAttrs) version src meta;

    pyproject = true;

    build-system = [ setuptools ];

    postPatch = ''
      # dont use cx_Freeze
      # fix: ValueError: Egg metadata expected ... but not found
      substituteInPlace setup.py \
        --replace-fail "from cx_Freeze import setup" "from setuptools import setup #" \
        --replace-fail \
          '    executables=[' \
          '    entry_points={"console_scripts": [".reticulum-meshchat-backend=reticulum_meshchat_backend.meshchat:main"]}); Executable = lambda *x, **y: None; dict(    executables=['

      mv src/backend src/reticulum_meshchat_backend

      substituteInPlace meshchat.py \
        --replace-fail 'from src.backend.' 'from .' \
        --replace-fail 'import database' 'from . import database; frontend_public_dir = os.environ["RETICULUM_MESHCHAT_FRONTEND_PUBLIC_DIR"]' \
        --replace-fail '"public/' 'frontend_public_dir + "/'

      mv -t src/reticulum_meshchat_backend meshchat.py database.py
    '';

    postInstall = ''
      cp -t $out/${python.sitePackages}/reticulum_meshchat_backend package.json
    '';

    dependencies = [
      aiohttp
      lxmf
      peewee
      rns
      websockets
    ];

    pythonImportsCheck = [
      "reticulum_meshchat_backend"
    ];

  };

})
