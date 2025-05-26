{
  symlinkJoin,
  makeWrapper,
  anki,
}:
symlinkJoin {
  name = "anki-wayland";
  paths = [ anki ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/anki" --set ANKI_WAYLAND 1
  '';
  inherit (anki) meta;
}
