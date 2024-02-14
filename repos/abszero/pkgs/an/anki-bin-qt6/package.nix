{ symlinkJoin
, makeWrapper
, anki-bin
, mpv-unwrapped
}:
symlinkJoin {
  name = "anki-bin-qt6";
  paths = [ anki-bin ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/anki" \
      --set DISABLE_QT5_COMPAT 1 \
      --prefix PATH : "${mpv-unwrapped}/bin" # Required for audio
  '';
}
