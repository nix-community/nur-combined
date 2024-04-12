{ lib
, fetchFromGitHub
, buildNpmPackage
, toml2json
, nodejs
, ffmpeg
, substituteAll
, makeWrapper
, callPackage
}:

# This is an adaptation with buildNpmPackage based on https://github.com/milahu/nur-packages/commit/3022ffb3619182ffcd579194e1202e3978e4d55b

let
  filepicker = callPackage ./filepicker.nix { };

in
buildNpmPackage rec {
  pname = "vdhcoapp";
  version = "2.0.19";

  src = fetchFromGitHub {
    owner = "aclap-dev";
    repo = "vdhcoapp";
    rev = "v${version}";
    hash = "sha256-8xeZvqpRq71aShVogiwlVD3gQoPGseNOmz5E3KbsZxU=";
  };

  sourceRoot = "${src.name}/app";
  npmDepsHash = "sha256-E032U2XZdyTER6ROkBosOTn7bweDXHl8voC3BQEz8Wg=";
  dontNpmBuild = true;

  nativeBuildInputs = [
    toml2json
    makeWrapper
  ];

  patches = [
    (substituteAll {
      src = ./code.patch;
      inherit ffmpeg;
      filepicker = lib.getExe filepicker;
    })
  ];

  postPatch = ''
    # Cannot use patch, setting placeholder here
    substituteInPlace src/native-autoinstall.js \
      --replace process.execPath "\"${placeholder "out"}/bin/vdhcoapp\""
  '';

  preBuild = ''
    toml2json --pretty ../config.toml > src/config.json
  '';

  installPhase = ''
    mkdir -p $out/opt/vdhcoapp

    cp -r . "$out/opt/vdhcoapp"

    makeWrapper ${nodejs}/bin/node $out/bin/vdhcoapp \
      --add-flags $out/opt/vdhcoapp/src/main.js
  '';

  meta = with lib; {
    description = "Companion application for the Video DownloadHelper browser add-on";
    homepage = "https://www.downloadhelper.net/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ wolfangaukang ];
    mainProgram = "vdhcoapp";
  };
}
 
