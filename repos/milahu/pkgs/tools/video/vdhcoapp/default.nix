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
in

stdenvNoCC.mkDerivation rec {

  pname = "vdhcoapp";
  version = "2.0.19";

  #src = ./src/vdhcoapp;
  src = fetchFromGitHub {
    owner = "aclap-dev";
    repo = "vdhcoapp";
    rev = "v${version}";
    hash = "sha256-8xeZvqpRq71aShVogiwlVD3gQoPGseNOmz5E3KbsZxU=";
  };

  node_modules = npmlock2nix.node_modules {
    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;
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
    sed -i '1 i\#!${nodejs}/bin/node\n' app/src/main.js

    chmod +x app/src/main.js

    ln -s ${node_modules}/node_modules app/
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
