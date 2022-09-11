{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, which
, autoconf
, automake
, libtool
, libpcap
, json_c
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "ndpi";
  version = "rev-8b2c9860be8b0663bfe9fc3b6defc041bb90e5b2";

  src = fetchFromGitHub {
    owner = "ntop";
    repo = "nDPI";
    rev = "8b2c9860be8b0663bfe9fc3b6defc041bb90e5b2";
    sha256 = "sha256-b6SHY86cakFsuH2l9y22qht4B2Q9W3N3srWWLK0oJoQ=";
  };

  configureScript = "./autogen.sh";

  nativeBuildInputs = [ which autoconf automake libtool pkg-config ];
  buildInputs = [
    libpcap
    json_c
  ];

  meta = with lib; {
    description = "A library for deep-packet inspection";
    longDescription = ''
      nDPI is a library for deep-packet inspection based on OpenDPI.
    '';
    homepage = "https://www.ntop.org/products/deep-packet-inspection/ndpi/";
    license = with licenses; [ lgpl3Plus bsd3 ];
    maintainers = with maintainers; [ takikawa ];
    mainProgram = "ndpiReader";
    platforms = with platforms; unix;
  };
}
