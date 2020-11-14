{ stdenv, lib,
  fetchFromGitHub,
  autoconf, automake }:

stdenv.mkDerivation rec {
  pname = "n2n";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "ntop";
    repo = pname;
    rev = version;
    hash = "sha256:16xsrgp7wa5p0i780vaz9cl4wkqab46z35w50pj2abahg1msb6l9";
  };

  nativeBuildInputs = [ autoconf automake ];

  preConfigure = ''
    bash ./autogen.sh
  '';

  patches = [
    ./darwin-local-sbin-to-sbin.patch
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "A layer two peer-to-peer VPN (with patches: darwin-local-sbin-to-sbin.patch)";
    license = lib.licenses.gpl3;
    homepage = https://ntop.org/n2n/;
  };
}
