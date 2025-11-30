{ lib
, stdenv
, python3
, fetchFromGitHub
, ffmpeg-headless
, makeWrapper
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    eyed3
    lxml
    protobuf
    pydub
    tinytag
    tqdm
  ]);
in
stdenv.mkDerivation rec {
  pname = "mixxx-to-rekordbox";
  version = "0.1.0-unstable-2025-10-28";

  src = fetchFromGitHub {
    owner = "TheKantankerus";
    repo = "MixxxToRekordbox";
    rev = "1dbc393e72ede9a6a39e286362ec88de05254f56";
    hash = "sha256-B4YnubS46ktGSK7D564v77GPzX8brjkiIFJsx9jmT78=";
  };

  patches = [
    ./mixxx-to-rekordbox/0001-fix-db-discovery-in-linux-and-mac.patch
    ./mixxx-to-rekordbox/0002-make-track-loading-robust-against-non-existent-track.patch
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/mixxx-to-rekordbox $out/bin
    cp -r . $out/lib/mixxx-to-rekordbox/

    makeWrapper ${pythonEnv}/bin/python $out/bin/mixxx-to-rekordbox \
      --add-flags "$out/lib/mixxx-to-rekordbox/main.py" \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg-headless ]}

    runHook postInstall
  '';

  meta = {
    description = "Sync your Mixxx Playlists to Rekordbox XML, optionally reformatting your files";
    homepage = "https://github.com/TheKantankerus/MixxxToRekordbox";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.bendlas ];
    mainProgram = "mixxx-to-rekordbox";
    platforms = lib.platforms.all;
  };
}
