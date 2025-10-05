{
  lib,
  stdenv,
  fetchFromGitHub,
  perlPackages,
  shortenPerlShebang,
}:

perlPackages.buildPerlPackage {
  pname = "gpx-layer";
  version = "0-unstable-2013-09-19";

  src = fetchFromGitHub {
    owner = "e-n-f";
    repo = "gpx-layer";
    rev = "746b4723cf1f69fb86d45cf2d4efeaae9e711d2d";
    hash = "sha256-I9/ZkfrDNT0AZzcUAIShfSviP5dLvVvByJW6UrF0u2w=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = lib.optional stdenv.isDarwin shortenPerlShebang;

  propagatedBuildInputs = [ perlPackages.XMLParser ];

  preConfigure = "touch Makefile.PL";

  installPhase =
    ''
      install -Dm755 parse-gpx $out/bin/datamaps-parse-gpx
    ''
    + lib.optionalString stdenv.isLinux ''
      patchShebangs $out/bin/datamaps-parse-gpx
    ''
    + lib.optionalString stdenv.isDarwin ''
      shortenPerlShebang $out/bin/datamaps-parse-gpx
    '';

  meta = {
    description = "Tools to turn GPX files into a GPS map tracing layer";
    homepage = "https://github.com/e-n-f/gpx-layer";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
