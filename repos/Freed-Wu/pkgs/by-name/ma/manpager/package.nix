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
  # --prefix allow user to use less from $PATH
  postFixup = ''
    sed -i 's=\$0='$out'/bin/manpager=' $out/bin/manpager
    wrapProgram $out/bin/manpager --prefix PATH : "${
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
