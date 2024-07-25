{
  symlinkJoin,
  makeWrapper,
  anki,
}:
symlinkJoin {
  name = "anki-qt6-wayland";
  paths = [ anki ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/anki" --set DISABLE_QT5_COMPAT 1 --set ANKI_WAYLAND 1
  '';
}
