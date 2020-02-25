{ lib, buildPerlPackage, sources, ConfigStd, EncodeLocale
, FileSlurp, GeoOpenstreetmapParser, JSON, ListMoreUtils
, LWPProtocolHttps, MatchSimple, MathPolygon, MathPolygonTree
, TemplateToolkit, TextUnidecode, TreeR, YAML }:

buildPerlPackage rec {
  pname = "osm2mp";
  version = lib.substring 0 7 src.rev;
  src = sources.osm2mp;

  outputs = [ "out" ];

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

  preConfigure = ''
    patchShebangs .
    touch Makefile.PL
  '';

  installPhase = ''
    install -Dm755 osm2mp.pl $out/bin/osm2mp
    install -dm755 $out/share/osm2mp/cfg
    cp -r cfg/* $out/share/osm2mp/cfg
    install -dm755 $out/lib/perl5/site_perl
    cp -r lib/* $out/lib/perl5/site_perl
  '';

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.gpl2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
