{ lib
, stdenv
, buildPerlPackage
, shortenPerlShebang
, fetchFromGitHub
, ConfigStd
, EncodeLocale
, FileSlurp
, GeoOpenstreetmapParser
, JSON
, ListMoreUtils
, LWPProtocolHttps
, MatchSimple
, MathPolygon
, MathPolygonTree
, TemplateToolkit
, TextUnidecode
, TreeR
, YAML
}:

buildPerlPackage rec {
  pname = "osm2mp";
  version = "2018-08-31";

  src = fetchFromGitHub {
    owner = "liosha";
    repo = "osm2mp";
    rev = "748f93792ead174ad0e94a183a173ef3fcacf200";
    hash = "sha256-YxtEOuoLeglpdpmStrcEkXwRGHRE+N1hKDB2Rr8rokw=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = lib.optional stdenv.isDarwin shortenPerlShebang;

  propagatedBuildInputs = [
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
      --replace "\$Bin/cfg" "$out/share/osm2mp/cfg"
  '';

  preConfigure = "touch Makefile.PL";

  installPhase = ''
    install -Dm755 osm2mp.pl $out/bin/osm2mp
    install -dm755 $out/share/osm2mp/cfg
    cp -r cfg/* $out/share/osm2mp/cfg
    install -dm755 $out/lib/perl5/site_perl
    cp -r lib/* $out/lib/perl5/site_perl
  '' + lib.optionalString stdenv.isLinux ''
    patchShebangs $out/bin/osm2mp
  '' + lib.optionalString stdenv.isDarwin ''
    shortenPerlShebang $out/bin/osm2mp
  '';

  meta = with lib; {
    description = "Convert Openstreetmap data to MP format";
    inherit (src.meta) homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
  };
}
