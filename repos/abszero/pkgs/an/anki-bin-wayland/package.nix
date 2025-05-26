{
  symlinkJoin,
  makeWrapper,
  anki-bin,
  mpv-unwrapped,
}:
symlinkJoin {
  name = "anki-bin-wayland";
  paths = [ anki-bin ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/anki" \
      --set ANKI_WAYLAND 1 \
      --prefix PATH : "${mpv-unwrapped}/bin" # Required for audio
  '';
  inherit (anki-bin) meta;
}
