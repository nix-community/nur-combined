
{ stdenv, fetchFromGitHub, git }:

stdenv.mkDerivation rec {
  pname = "udp2raw";
  version = "20200818.0";
  nativeBuildInputs = [ git ];
  src = fetchFromGitHub {
    owner = "wangyu-";
    repo = "udp2raw";
    rev = "cc6ea766c495cf4c69d1c7485728ba022b0f19de";
    sha256 = "1pq6k5dwlv85g3fwizsq45fkgs8mg1ix4andnxrp4z2ibmycwi2f";
  };

  buildPhase = ''
    make dynamic
  '';

  installPhase = ''
    install -D -m755 udp2raw_dynamic $out/bin/udp2raw
  '';
}
