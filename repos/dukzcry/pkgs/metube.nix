{ stdenv, lib, buildNpmPackage, fetchFromGitHub, python311Packages
, makeWrapper, ffmpeg }:

let
  version = "2024-11-19";
  src = fetchFromGitHub {
    owner = "alexta69";
    repo = "metube";
    rev = "4a87e9fa68569e467224c8ef9cc49df8dfede831";
    hash = "sha256-thKEe9nMTWgecYoKrXzHpNO+Fmhrtj9ru5aNd2EhK38=";
  };
  metube_ui = buildNpmPackage rec {
    pname = "metube-ui";
    inherit version src;
    sourceRoot = "source/ui";
    npmDepsHash = "sha256-LJer26oDi30+wDmN8GFwQCw88Nu1CfWi4X8LJaAyeGo=";
  };
in stdenv.mkDerivation rec {
  pname = "metube";
  inherit version src;

  nativeBuildInputs = with python311Packages; [ wrapPython makeWrapper ];

  pythonPath = with python311Packages; [ pylint aiohttp python-socketio yt-dlp ];

  postFixup = ''
    mkdir -p $out/app $out/ui $out/bin
    cp -r app/* $out/app
    chmod +x $out/app/main.py
    sed -i '1i #!/usr/bin/env python3' $out/app/dl_formats.py $out/app/ytdl.py
    substituteInPlace $out/app/main.py \
      --replace-fail "ui/dist/metube" "$out/ui/dist/metube"
    cp -r ${metube_ui}/lib/node_modules/metube/dist $out/ui
    wrapPythonProgramsIn $out/app "$out $pythonPath"
    makeWrapper $out/app/main.py $out/bin/metube \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  meta = {
    description = "Self-hosted YouTube downloader (web UI for youtube-dl / yt-dlp)d";
    homepage = "https://github.com/alexta69/metube";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "metube";
  };
}
