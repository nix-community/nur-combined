{ stdenv, fetchzip, autoPatchelfHook }:

let game = "zuniq";
in stdenv.mkDerivation {
  name = "caia";

  src = fetchzip {
    url =
      "https://www.codecup.nl/download/caia_zuniq/linux64/caia_zuniq_linux64.tar.gz";
    sha256 = "0xiyv4hhqfvgn166fqnyrvnlrrfhs2crkbyagd1ayvbvaxwx1yi4";
  };

  patches = [ ./manager-patch.diff ./manager-patch2.diff ];

  # Patch the player{1,2,3} and referee binaries
  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];
  # Stops patching caiaio
  dontAutoPatchelf = true;

  preFixup = ''
    autoPatchelf $out/caia/${game}/bin/player1
    autoPatchelf $out/caia/${game}/bin/player2
    autoPatchelf $out/caia/${game}/bin/player3
    autoPatchelf $out/caia/${game}/bin/referee
  '';

  buildPhase = ''
    export HOME=$out
    mkdir -p $out

    patchShebangs .
    ./install_game.sh ${game}
  '';

  installPhase = ''
    mkdir -p $out/bin
    ln -s $out/caia/${game}/bin/caiaio $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "The program tester and competition runner for CodeCup";
    homepage = "https://www.codecup.nl/download_caia.php";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
