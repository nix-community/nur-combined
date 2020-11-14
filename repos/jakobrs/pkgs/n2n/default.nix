{ stdenv, lib,
  fetchFromGitHub,
  autoconf, automake }:

stdenv.mkDerivation rec {
  pname = "n2n";
  version = "2.8";

  src = fetchFromGitHub {
    owner = "ntop";
    repo = pname;
    rev = version;
    hash = "sha256:1ph2npvnqh1xnmkp96pdzpxm033jkb8zznd3nc59l9arhn0pq4nv";
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
