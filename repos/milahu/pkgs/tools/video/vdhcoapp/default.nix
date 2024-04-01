/*
  based on
  https://codeberg.org/wolfangaukang/nix-agordoj/src/branch/vdhcoapp-2.0.0/pkgs/vdhcoapp

  via
  https://github.com/NixOS/nixpkgs/issues/112046#issuecomment-1917622236

  by default, errors are not logged. fix:
  WEH_NATIVE_LOGFILE=/dev/stderr ./result/bin/vdhcoapp
*/

{ lib
, stdenvNoCC
, fetchFromGitHub
, npmlock2nix
, toml2json
, ffmpeg
, nodejs
, callPackage
}:

let
  filepicker = callPackage ./filepicker.nix { };
  stdenv = stdenvNoCC;
in

stdenv.mkDerivation rec {

  pname = "vdhcoapp";
  version = "2.0.19";

  src =
  #if true then ./src/vdhcoapp else
  fetchFromGitHub {
    owner = "aclap-dev";
    repo = "vdhcoapp";
    /*
    rev = "v${version}";
    hash = "sha256-8xeZvqpRq71aShVogiwlVD3gQoPGseNOmz5E3KbsZxU=";
    */
    # https://github.com/aclap-dev/vdhcoapp/pull/218
    # generate config files on build time
    rev = "548f6ec2366713a4b3aa733a7164e668b9818c96";
    hash = "sha256-JstwbDlWiMxylxngjaChEgtpbkWobTkIywQERVTdqkw=";
  };

  node_modules = npmlock2nix.node_modules {
    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;

    # FIXME this requires custom node interpreter for main.js
    #symlinkNodeModules = true;

    # force rebuild
    #preBuild = '': # asdf'';
  };

  nativeBuildInputs = [
    toml2json
  ];

  buildPhase = ''
    toml2json --pretty config.toml >app/src/config.json

    # use system ffmpeg
    # https://github.com/aclap-dev/vdhcoapp/issues/49
    # disable "open"
    substituteInPlace app/src/converter.js \
      --replace \
        'const ffmpeg = findExecutableFullPath("ffmpeg", exec_dir);' \
        'const ffmpeg = "${ffmpeg}/bin/ffmpeg";' \
      --replace \
        'const ffprobe = findExecutableFullPath("ffprobe", exec_dir);' \
        'const ffprobe = "${ffmpeg}/bin/ffprobe";' \
      --replace \
        'const filepicker = findExecutableFullPath("filepicker", exec_dir);' \
        'const filepicker = "${filepicker}/bin/filepicker";' \
      --replace \
        "import open from 'open';" \
        "function open() {}" \

    # path:
    # originally, vdhcoapp is compiled into a single executable
    # whose path is process.execPath
    # but here, process.execPath is the node interpreter
    substituteInPlace app/src/native-autoinstall.js \
      --replace \
        "path: process.execPath," \
        "path: '$out/bin/vdhcoapp'," \
      --replace \
        "require('config.json')" \
        "require('./config.json')" \

    substituteInPlace app/src/main.js \
      --replace \
        "require('config.json')" \
        "require('./config.json')" \

    # add shebang line
    if [ "$(head -c2 app/src/main.js)" != "#!" ]; then
      sed -i '1 i\#!${nodejs}/bin/node\n' app/src/main.js
    fi

    chmod +x app/src/main.js

    ln -s ${node_modules}/node_modules app/

    # generate config files on build time
    # enable the original install function in native-autoinstall.js
    export VDHCOAPP_INSTALL_ON_BUILDTIME=1

    ${if !stdenv.hostPlatform.isLinux then "" else ''
      echo generating config files for linux
      export HOME=$PWD/app/config/linux
      grep '^only_if_dir_exists = "~/\.' config.toml | cut -d'"' -f2 |
        while read d; do mkdir -p "$HOME/''${d:2}"; done
      ./app/src/main.js install
      # fix https://github.com/aclap-dev/vdhcoapp/issues/195
      ln -srT app/config/linux/.mozilla app/config/linux/.librewolf
    ''}

    ${if !stdenv.hostPlatform.isDarwin then "" else ''
      echo generating config files for darwin
      export HOME=$PWD/app/config/darwin
      grep '^only_if_dir_exists = "~/Library/' config.toml | cut -d'"' -f2 |
        while read d; do mkdir -p "$HOME/''${d:2}"; done
      ./app/src/main.js install
    ''}
  '';

  installPhase = ''
    mkdir -p $out/opt
    cp -r app $out/opt/vdhcoapp

    mkdir -p $out/bin
    ln -sr $out/opt/vdhcoapp/src/main.js $out/bin/vdhcoapp
  '';

  meta = with lib; {
    description = "Companion app for Video DownloadHelper";
    homepage = "https://github.com/aclap-dev/vdhcoapp";
    license = licenses.gpl2;
    maintainers = [];
  };
}
