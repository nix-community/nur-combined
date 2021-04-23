{ lib, stdenv, fetchFromGitHub, buildPerlPackage, shortenPerlShebang, XMLParser }:

buildPerlPackage rec {
  pname = "gpx-layer";
  version = "2013-09-19";

  src = fetchFromGitHub {
    owner = "ericfischer";
    repo = pname;
    rev = "746b4723cf1f69fb86d45cf2d4efeaae9e711d2d";
    sha256 = "0v5vfjqm5flmr30mpgabjwzy4avxl620051pcw03sdf3za8xkpr3";
  };

  outputs = [ "out" ];

  nativeBuildInputs = lib.optional stdenv.isDarwin shortenPerlShebang;

  propagatedBuildInputs = [ XMLParser ];

  preConfigure = "touch Makefile.PL";

  installPhase = ''
    install -Dm755 parse-gpx $out/bin/datamaps-parse-gpx
  '' + lib.optionalString stdenv.isLinux ''
    patchShebangs $out/bin/datamaps-parse-gpx
  '' + lib.optionalString stdenv.isDarwin ''
    shortenPerlShebang $out/bin/datamaps-parse-gpx
  '';

  meta = with lib; {
    description = "Tools to turn GPX files into a GPS map tracing layer";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
