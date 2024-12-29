{
  mySources,
  lib,
  stdenvNoCC,
  bat,
  ansifilter,
  makeWrapper,
}:
stdenvNoCC.mkDerivation {
  inherit (mySources.manpager) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -D bin/manpager -t $out/bin
    runHook postInstall
  '';
  postFixup = ''
    wrapProgram $out/bin/manpager --set PATH "${
      lib.makeBinPath [
        bat
        ansifilter
      ]
    }"
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/manpager";
    description = "Colorize `man XXX`";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
