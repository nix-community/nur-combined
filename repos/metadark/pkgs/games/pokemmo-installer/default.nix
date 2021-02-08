{ lib
, stdenv
, fetchFromGitLab
, makeWrapper
, coreutils
, findutils
, gnugrep
, jre
, openssl
, ps
, wget
, which
, xprop
, zenity
, libpulseaudio
}:

stdenv.mkDerivation rec {
  pname = "pokemmo-installer";
  version = "1.4.8";

  src = fetchFromGitLab {
    owner = "coringao";
    repo = pname;
    rev = version;
    hash = "sha256:0fpiq4bynrk7p3bv7sxfx7yldf2glh4frm50bwyn6y3439fff9mr";
  };

  nativeBuildInputs = [ makeWrapper ];

  installFlags = [
    "PREFIX=${placeholder "out"}"

    # BINDIR defaults to $(PREFIX)/games
    "BINDIR=${placeholder "out"}/bin"
  ];

  postFixup = ''
    wrapProgram "$out/bin/${pname}" \
      --prefix PATH : ${lib.makeBinPath [
        coreutils
        findutils
        gnugrep
        jre
        openssl
        ps
        wget
        which
        xprop
        zenity
      ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        libpulseaudio
      ]}
  '';

  meta = with lib; {
    description = "Installer and Launcher for the PokeMMO emulator";
    homepage = "https://pokemmo.eu";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.linux;
  };
}
