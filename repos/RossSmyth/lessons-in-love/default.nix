{
  lib,
  buildRenpyGame,
  requireFile,
  fetchItchIo,
  unrar-free,
}:
let
  august2023 = requireFile {
    name = "august-2023-08.rar";
    url = "https://www.lessonsinlovegame.com/download/care-packages/";
    hash = "sha256-QQSoi5gsuFnK+OcLIiB90aY3MAwCC98a/QdlLPIvg6U=";
  };
  june2023 = requireFile {
    name = "june-2023-care-package.zip";
    url = "https://www.lessonsinlovegame.com/download/care-packages/";
    hash = "sha256-+D1kIaG2oFHDhE/grciTcJdp+Ig7vw+bTFEgw0vd2ZA=";
  };
in
buildRenpyGame (finalAttrs: {
  pname = "lessons-in-love";
  version = "0.61.1";
  gameName = "Lessons in Love";

  src = fetchItchIo {
    # This is from the gdrive
    name = "LessonsInLove0.61.1-0.61.1-pc-subscribestar.zip";
    gameUrl = "https://djnostyle.itch.io/lessons-in-love";
    upload = "idk-yet";
    hash = "sha256-x+cG3QM/N2qJpYzZAW3tOnNSjl99jxzlV5QEdECEGIc=";
  };

  nativeBuildInputs = [
    unrar-free
  ];

  postPatch = ''
    august2023=$(mktemp -d)
    june2023=$(mktemp -d)

    7zz x -o"$june2023" "${june2023}"
    unrar-free x "${august2023}" "$august2023"

    cp -r -- "$august2023/"*/game/* game/
    cp -r -- "$june2023/"*/game/* game/
  '';
})
