{
  sources,
  python3Packages,
  lib,
  beets,
}:
python3Packages.buildPythonApplication {
  inherit (sources.beets-lyricsmanager) pname src;
  version = sources.beets-lyricsmanager.date;

  format = "setuptools";

  nativeBuildInputs = [ beets ];

  meta = {
    description = "Beets plugin for automatically managing lyrics files (.lrc) when importing music files and synchronizing lyrics files when moving songs";
    homepage = "https://github.com/zytx/beets-lyrics-manager";
    license = lib.licenses.mit;
    inherit (beets.meta) platforms;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
