{ lib
, stdenv
, buildPerlPackage
, shortenPerlShebang
, sources
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

buildPerlPackage {
  pname = "osm2mp";
  version = lib.substring 0 10 sources.osm2mp.date;

  src = sources.osm2mp;

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
    inherit (sources.osm2mp) description homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
