{
  lib,
  stdenv,
  perlPackages,
  shortenPerlShebang,
  fetchFromGitHub,
}:

perlPackages.buildPerlPackage {
  pname = "osm2mp";
  version = "0-unstable-2018-08-31";

  src = fetchFromGitHub {
    owner = "liosha";
    repo = "osm2mp";
    rev = "748f93792ead174ad0e94a183a173ef3fcacf200";
    hash = "sha256-YxtEOuoLeglpdpmStrcEkXwRGHRE+N1hKDB2Rr8rokw=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = lib.optional stdenv.isDarwin shortenPerlShebang;

  propagatedBuildInputs = with perlPackages; [
    ConfigStd
    EncodeLocale
    FileSlurp
    GeoOpenstreetmapParser
    JSON
    ListMoreUtils
    LWPProtocolHttps
    MatchSimple
    MathPolygon
    MathPolygonTree
    TemplateToolkit
    TextUnidecode
    TreeR
    YAML
  ];

  postPatch = ''
    substituteInPlace osm2mp.pl \
      --replace-fail "\$Bin/cfg" "$out/share/osm2mp/cfg"
  '';

  preConfigure = "touch Makefile.PL";

  installPhase =
    ''
      install -Dm755 osm2mp.pl $out/bin/osm2mp
      install -dm755 $out/share/osm2mp/cfg
      cp -r cfg/* $out/share/osm2mp/cfg
      install -dm755 $out/lib/perl5/site_perl
      cp -r lib/* $out/lib/perl5/site_perl
    ''
    + lib.optionalString stdenv.isLinux ''
      patchShebangs $out/bin/osm2mp
    ''
    + lib.optionalString stdenv.isDarwin ''
      shortenPerlShebang $out/bin/osm2mp
    '';

  meta = {
    description = "Convert Openstreetmap data to MP format";
    homepage = "https://github.com/liosha/osm2mp";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "osm2mp";
  };
}
