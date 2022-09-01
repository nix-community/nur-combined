{ lib, stdenv, fetchurl, perlPackages }:
with perlPackages;
rec {
  MatchSimple = buildPerlPackage rec {
    pname = "match-simple";
    version = "0.010";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TOBYINK/${pname}-${version}.tar.gz";
      hash = "sha256-itYBTU5AJA3DNY+9yQf9OZJlUcGAs6Qnn42hgfF/dss=";
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
      hash = "sha256-XK6q2marSv39rlbAI+CZiAVDqafB+THyCoNNWIHBXss=";
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
      hash = "sha256-Ag1fbn/z2hfkhSNN+16TVSjmd01XYJQ9h2X6sCvfwtc=";
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
      hash = "sha256-nJDRHywc/80cD/OxOCXyxWt/rywwdNbau7LckIHVYow=";
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
      hash = "sha256-9FFJ/+vmZMR/oKBxCYLtmpPnaFe2KYRDYZpdSs7sskE=";
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
      hash = "sha256-7fEpfcWbjahnO9Oz/Y7eif15cqcD/5B7F2b/xwLbVDg=";
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
      hash = "sha256-iygsM5Ha+hy4MN8Q4aLoRfpScYzYSSe73bDnyqofRpM=";
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
      hash = "sha256-muwoy5iLY2UsU89XaohMDVvaTKzpOu8ui4vx11H4mco=";
    };
    propagatedBuildInputs = [ ListMoreUtils EncodeLocale ];
    meta = with lib; {
      homepage = "https://metacpan.org/pod/Geo::Names::Russian";
      description = "Geo::Names::Russian - parse and split russian geographical names";
      license = licenses.free;
    };
  };

  DateTimeFormatEXIF = buildPerlPackage rec {
    pname = "DateTime-Format-EXIF";
    version = "0.002";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LI/LIOSHA/${pname}-${version}.tar.gz";
      hash = "sha256-a3S36YhWUYKJiMEy0nBqedJtlhZlddyeO3MFmoLhXTE=";
    };
    propagatedBuildInputs = [ DateTimeFormatBuilder ];
    meta = with lib; {
      homepage = "https://metacpan.org/pod/DateTime::Format::EXIF";
      description = "DateTime::Format::EXIF - DateTime parser for EXIF timestamps";
      license = licenses.free;
    };
  };

  IpcShareLite = buildPerlPackage rec {
    pname = "IPC-ShareLite";
    version = "0.17";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AN/ANDYA/${pname}-${version}.tar.gz";
      hash = "sha256-FNQGuR2pbWUh0NGoLSKjBidHZSJrhrClbn/93Plq578=";
    };
    propagatedBuildInputs = [  ];
    meta = with lib; {
      homepage = "https://metacpan.org/pod/IPC::ShareLite";
      description = "IPC::ShareLite - Lightweight interface to shared memory";
      license = licenses.free;
    };
  };
}
