{
  lib,
  stdenv,
  makeWrapper,
  mkvtoolnix,
  python3,
}:

stdenv.mkDerivation {
  pname = "fix-entities";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    install -D -m 755 fix-entities.sh $out/bin/fix-entities
    wrapProgram $out/bin/fix-entities \
      --prefix PATH : "${
        lib.makeBinPath [
          mkvtoolnix
          python3
        ]
      }"
  '';

  meta = with lib; {
    description = "Strip raw HTML entities from embedded SubRip subtitle tracks of mkv files";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "fix-entities";
  };
}
