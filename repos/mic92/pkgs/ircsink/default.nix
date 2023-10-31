{ lib
, stdenv
, fetchgit
, coreutils
, gawk
, gnused
, netcat
, nettools
, unixtools
, makeWrapper
, openssl
}:

stdenv.mkDerivation rec {
  pname = "ircsink";
  version = "1.2.0";

  src = fetchgit {
    url = "https://cgit.krebsco.de/ircaids";
    rev = version;
    sha256 = "sha256-D4+9xPA6x8RuNSsTOxxpL5Kv4lmU/wtwSjY7SkmxNBE=";
  };
  nativeBuildInputs = [
    makeWrapper
  ];
  installPhase = ''
    runHook preInstall
    install -D -m755 bin/ircsink $out/bin/ircsink
    wrapProgram $out/bin/ircsink \
      --prefix PATH : ${lib.makeBinPath [
        coreutils
        unixtools.getopt
        gawk
        gnused
        netcat
        openssl
        nettools
      ]}
    runHook postInstall
  '';
  meta = with lib; {
    description = "IRC notifications implemented as a shell script";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
