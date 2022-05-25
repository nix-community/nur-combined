{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "freqtop";
  version = "2022-02-01";

  src = fetchFromGitHub {
    owner = "stolk";
    repo = "freqtop";
    rev = "d364fe9207e1d89e91bdbe67ca4d49c94ce0d6e0";
    sha256 = "06qb8mxcpgnsd6f069lfmag719qdi7kwak8q61isqwilwdcs4qg5";
  };

  installPhase = ''
    install -D -m755 freqtop $out/bin/freqtop
  '';

  meta = with lib; {
    description = "Monitor for the CPU Frequency Scaling under Linux";
    homepage = "https://github.com/stolk/freqtop";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fliegendewurst ];
  };
}
