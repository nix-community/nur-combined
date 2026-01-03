{
  stdenv,
  lib,
  wrapProgram,
  gnugrep,
}:
stdenv.mkDerivation rec {
  pname = "mkwindows-tools";
  version = "1.0.0";
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin

    install -D gc.bash $out/bin/mkwindows-tools-gc
  '';

  postInstall = ''
    wrapProgram $out/bin/mkwindows-tools-gc --prefix PATH : ${lib.makeBinPath [ gnugrep ]}
  '';

  meta = with lib; {
    description = "A set of tools for working with packages made with mkWindowsApp.";
    homepage = "https://github.com/emmanuelrosa/erosanix";
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
    mainProgram = "mkwindows-tools-gc";
  };
}
