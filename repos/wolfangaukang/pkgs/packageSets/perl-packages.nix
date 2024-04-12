{ lib
, stdenv
, perlPackages
, fetchurl
, shortenPerlShebang
}:

let
  inherit (perlPackages) buildPerlModule buildPerlPackage;

in
rec {
  ARGVStruct = buildPerlPackage {
    pname = "ARGV-Struct";
    version = "0.06";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JL/JLMARTIN/ARGV-Struct-0.06.tar.gz";
      hash = "sha256-ou8XTjVjLBtuv/6Km2N0yKbUrf2jXSr+HnMIAkRLX2k=";
    };
    buildInputs = with perlPackages; [ TestException ];
    propagatedBuildInputs = with perlPackages; [ Moo TypeTiny ];
    meta = {
      description = "Parse complex data structures passed in ARGV";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  ConfigAWS = buildPerlModule {
    pname = "Config-AWS";
    version = "0.12";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JJ/JJATRIA/Config-AWS-0.12.tar.gz";
      hash = "sha256-FQnRvzi/cpHuouXEj83GvSWQS8h6tstv/qZANkewa1o=";
    };
    buildInputs = with perlPackages; [ ModuleBuildTiny Test2Suite ];
    propagatedBuildInputs = with perlPackages; [ ExporterTiny PathTiny RefUtil ];
    meta = {
      description = "Parse AWS config files";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  DataStructFlat = buildPerlPackage {
    pname = "DataStruct-Flat";
    version = "0.01";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JL/JLMARTIN/DataStruct-Flat-0.01.tar.gz";
      hash = "sha256-b2TixvR15tCsahd68Gmg5ShfURHeWWUKv5Mx0iqcC7s=";
    };
    propagatedBuildInputs = with perlPackages; [ Moo ];
    meta = {
      description = "Convert a data structure into a one level list of keys and values";
      license = lib.licenses.asl20;
    };
  };
  MooseXClassAttribute = buildPerlPackage {
    pname = "MooseX-ClassAttribute";
    version = "0.29";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DR/DROLSKY/MooseX-ClassAttribute-0.29.tar.gz";
      hash = "sha256-YUTHfFJ3DU+DHK22yto3ElyAs+T/yyRtp+6dVZIu5yU=";
    };
    buildInputs = with perlPackages; [ TestFatal TestRequires ];
    propagatedBuildInputs = with perlPackages; [ Moose namespaceautoclean namespaceclean ];
    meta = {
      homepage = "http://metacpan.org/release/MooseX-ClassAttribute";
      description = "Declare class attributes Moose-style";
      license = lib.licenses.artistic2;
    };
  };
  NetAmazonSignatureV4 = buildPerlPackage {
    pname = "Net-Amazon-Signature-V4";
    version = "0.21";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DB/DBOOK/Net-Amazon-Signature-V4-0.21.tar.gz";
      hash = "sha256-WZy3ZsBV9sSNNiWX51NckCzWZ05NatHOTLCOjQZ3f9E=";
    };
    buildInputs = with perlPackages; [ FileSlurper HTTPMessage ];
    propagatedBuildInputs = with perlPackages; [ URI ];
    meta = {
      description = "Implements the Amazon Web Services signature version 4, AWS4-HMAC-SHA256";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  TestTimer = buildPerlPackage {
    pname = "Test-Timer";
    version = "2.12";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JO/JONASBN/Test-Timer-2.12.tar.gz";
      hash = "sha256-6xtcGZeTzBxZGj0f5dFcFv2lOXVbptXdITjVY4gh8vw=";
    };
    buildInputs = with perlPackages; [ PodCoverageTrustPod TestFatal TestKwalitee TestPod TestPodCoverage ];
    propagatedBuildInputs = with perlPackages; [ Error ];
    meta = {
      homepage = "https://jonasbn.github.io/perl-test-timer/";
      description = "Test module to test/assert response times";
      license = lib.licenses.artistic2;
    };
  };
  URLEncode = buildPerlPackage {
    pname = "URL-Encode";
    version = "0.03";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CH/CHANSEN/URL-Encode-0.03.tar.gz";
      hash = "sha256-cpXX8HeWsXkTHZwPIwpu/6VtIE3i+Nxy8uCcYUWMjuY=";
    };
    meta = {
      description = "Encoding and decoding of C<application/x-www-form-urlencoded> encoding";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  URLEncodeXS = buildPerlPackage {
    pname = "URL-Encode-XS";
    version = "0.03";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CH/CHANSEN/URL-Encode-XS-0.03.tar.gz";
      hash = "sha256-1E9Ba9PljjszZqtCBwXaAscRj8hIqXzgiTZuoEYfqCM=";
    };
    propagatedBuildInputs = [ URLEncode ];
    meta = {
      description = "XS implementation of URL::Encode";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  Paws = buildPerlModule {
    pname = "Paws";
    version = "0.44";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JL/JLMARTIN/Paws-0.44.tar.gz";
      hash = "sha256-g8lSEpygoQNfvT7Oa97d9bOaVH0986cl5BKD+QGEHmQ=";
    };
    nativeBuildInputs = [ shortenPerlShebang ];
    buildInputs = (with perlPackages; [ ClassUnload FileSlurper ModuleBuildTiny PathClass TestException TestWarnings YAML ]) ++ [ TestTimer ];
    propagatedBuildInputs = with perlPackages; [ DataCompare DateTime DateTimeFormatISO8601 FileHomeDir IOSocketSSL JSONMaybeXS ModuleFind Moose MooseXGetopt PathTiny StringCRC32 Throwable URI URITemplate XMLSimple ] ++ [ ARGVStruct ConfigAWS DataStructFlat MooseXClassAttribute NetAmazonSignatureV4 URLEncode URLEncodeXS ];
    postInstall = ''
      for script in $out/bin/*; do
        shortenPerlShebang $script
      done

      substituteInPlace $out/bin/paws_make_testcase \
        --replace "bin/paws" "$out/bin/paws"
    '';
    checkInputs = with perlPackages; [ TestMore ];
    doCheck = false;
    meta = {
      description = "A Perl SDK for AWS (Amazon Web Services) APIs";
      license = lib.licenses.asl20;
    };
  };
}
