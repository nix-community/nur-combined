{
  stdenv,
  lib,
  makeWrapper,
  coreutils,
  gnugrep,
}:
stdenv.mkDerivation {
  pname = "mkwindows-tools";
  version = "1.0.0";
  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -D gc.bash $out/bin/mkwindows-tools-gc

    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/mkwindows-tools-gc --prefix PATH : ${
      lib.makeBinPath [
        coreutils
        gnugrep
      ]
    }
  '';

  meta = with lib; {
    description = "A set of tools for working with packages made with mkWindowsApp";
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
