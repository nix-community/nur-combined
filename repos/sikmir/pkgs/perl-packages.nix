{ lib, stdenv, fetchurl, perlPackages }:
with perlPackages;
rec {
  MatchSimple = buildPerlPackage rec {
    pname = "match-simple";
    version = "0.010";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TOBYINK/${pname}-${version}.tar.gz";
      sha256 = "1jvngzqq38cdkwks9cw0q58nb4irzl3wkgcg6p1hs9209r6h3mla";
    };
    buildInputs = [ TestFatal ];
    propagatedBuildInputs = [ ExporterTiny ScalarListUtils SubInfix ];
    meta = with lib; {
      homepage = "https://metacpan.org/pod/match::smart";
      description = "match::smart - clone of smartmatch operator";
      license = licenses.free;
    };
  };

  SubInfix = buildPerlPackage rec {
    pname = "Sub-Infix";
    version = "0.004";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TOBYINK/${pname}-${version}.tar.gz";
      sha256 = "1jsyq60mhkc31br33yf1lyll61c8k7h27h2nmvyzsjmbcvdambjw";
    };
    buildInputs = [ TestFatal ];
    meta = with lib; {
      homepage = "https://metacpan.org/pod/Sub::Infix";
      description = "Sub::Infix - create a fake infix operator";
      license = licenses.free;
    };
  };

  MathPolygon = buildPerlPackage rec {
    pname = "Math-Polygon";
    version = "1.10";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MA/MARKOV/${pname}-${version}.tar.gz";
      sha256 = "1my2vwmv1yk5hwyr8q2p9mvyca2mjdggnk93hpj1gnpkgxp5y382";
    };
    meta = with lib; {
      homepage = "https://metacpan.org/pod/Math::Polygon";
      description = "Math::Polygon - Class for maintaining polygon data";
      license = licenses.free;
    };
  };

  MathPolygonTree = buildPerlPackage rec {
    pname = "Math-Polygon-Tree";
    version = "0.08";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LI/LIOSHA/${pname}-${version}.tar.gz";
      sha256 = "1332sn0r1p5jpgddcx1h5jppysy5y8jkicgk1wfcvzqw5hgx344w";
    };
    propagatedBuildInputs = [ ListMoreUtils MathGeometryPlanarGPCPolygonXS ];
    meta = with lib; {
      homepage = "https://metacpan.org/pod/Math::Polygon::Tree";
      description = "Math::Polygon::Tree - fast check if point is inside polygon";
      license = licenses.free;
    };
  };

  MathGeometryPlanarGPCPolygonXS = buildPerlPackage rec {
    pname = "Math-Geometry-Planar-GPC-PolygonXS";
    version = "0.052";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LI/LIOSHA/${pname}-${version}.tar.gz";
      sha256 = "0hdjxk74lpcsc51q8adnaxlfg4wsxn10jwd0l1zw8r76xgzljlgl";
    };
    meta = with lib; {
      homepage = "https://metacpan.org/pod/Math::Geometry::Planar::GPC::PolygonXS";
      description = "Math::Geometry::Planar::GPC::PolygonXS - OO wrapper to gpc library (translated from Inline-based Math::Geometry::Planar::GPC::Polygon to XS)";
      license = licenses.free;
    };
  };

  TreeR = buildPerlPackage rec {
    pname = "Tree-R";
    version = "0.072";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AJ/AJOLMA/${pname}-${version}.tar.gz";
      sha256 = "0f2lvc1cgzv62xxr1zq3lxr7kzc9vs7gvcyk7dksi3cvqmyjkwgd";
    };
    meta = with lib; {
      homepage = "https://metacpan.org/pod/Tree::R";
      description = "Tree::R - Perl extension for the R-tree data structure and algorithms";
      license = licenses.free;
    };
  };

  GeoOpenstreetmapParser = buildPerlPackage rec {
    pname = "Geo-Openstreetmap-Parser";
    version = "0.03";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LI/LIOSHA/${pname}-${version}.tar.gz";
      sha256 = "14s63ymcmrxhvnxjfjfqiiqm5yj5x2if246z62w1rynsj4rjqa4b";
    };
    propagatedBuildInputs = [ ListMoreUtils XMLParser ];
    meta = with lib; {
      homepage = "https://metacpan.org/pod/Geo::Openstreetmap::Parser";
      description = "Geo::Openstreetmap::Parser - Openstreetmap XML dump parser";
      license = licenses.free;
    };
  };

  GeoNamesRussian = buildPerlPackage rec {
    pname = "Geo-Names-Russian";
    version = "0.02";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LI/LIOSHA/${pname}-${version}.tar.gz";
      sha256 = "1jlrz18xgwcbicpfyfp9mi6dlnqd9j46lmygacn6aqwbk35jiv4s";
    };
    propagatedBuildInputs = [ ListMoreUtils EncodeLocale ];
    meta = with lib; {
      homepage = "https://metacpan.org/pod/Geo::Openstreetmap::Parser";
      description = "Geo::Names::Russian - parse and split russian geographical names";
      license = licenses.free;
    };
  };

  DateTimeFormatEXIF = buildPerlPackage rec {
    pname = "DateTime-Format-EXIF";
    version = "0.002";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LI/LIOSHA/${pname}-${version}.tar.gz";
      sha256 = "0caxw619l1bk7fgdqxb52sb6vlkrd9qd4cn1i24q4lani3lvfx3b";
    };
    propagatedBuildInputs = [ DateTimeFormatBuilder ];
    meta = with lib; {
      homepage = "https://metacpan.org/pod/DateTime::Format::EXIF";
      description = "DateTime::Format::EXIF - DateTime parser for EXIF timestamps";
      license = licenses.free;
    };
  };
}
