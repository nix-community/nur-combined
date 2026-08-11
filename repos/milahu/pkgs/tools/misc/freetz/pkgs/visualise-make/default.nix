{ lib
, stdenvNoCC
, fetchurl
, makeWrapper
, freetz
, perl
, perlPackages
, graphviz
}:

let perlPackagesOld = perlPackages; in

let perlPackages = perlPackagesOld // (with perlPackagesOld; rec {

  # nix-generate-from-cpan Makefile::GraphViz
  MakefileGraphViz = buildPerlPackage {
    pname = "Makefile-GraphViz";
    version = "0.21";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AG/AGENT/Makefile-GraphViz-0.21.tar.gz";
      hash = "sha256-xswOPS35OlF6YmFuDyOKJR8/9W4culEKhru0wheiqQ0=";
    };
    doCheck = false; # FIXME some tests fail
    propagatedBuildInputs = [ graphviz GraphViz MakefileParser ];
    meta = {
      description = "Draw building flowcharts from Makefiles using GraphViz";
      license = lib.licenses.bsd3;
    };
  };

  # nix-generate-from-cpan Makefile::Parser
  MakefileParser = buildPerlPackage {
    pname = "Makefile-Parser";
    version = "0.216";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AG/AGENT/Makefile-Parser-0.216.tar.gz";
      hash = "sha256-/U+8aRxz4UPDMhgrpI30e1gNThIQEgDKdiXZ9jJT+9Y=";
    };
    buildInputs = [ IPCRun3 ];
    doCheck = false; # FIXME some tests fail
    propagatedBuildInputs = [ ClassAccessor ClassTrigger FileSlurp ListMoreUtils MakefileDOM ];
    meta = {
      description = "A simple parser for Makefiles";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  # nix-generate-from-cpan Class::Trigger
  ClassTrigger = buildPerlPackage {
    pname = "Class-Trigger";
    version = "0.15";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MI/MIYAGAWA/Class-Trigger-0.15.tar.gz";
      hash = "sha256-t6h41E3qZ9ZN8soYAg2dhoqVWW3r0W8aJkh0IJMysH8=";
    };
    buildInputs = [ IOStringy ];
    meta = {
      homepage = "https://github.com/miyagawa/Class-Trigger";
      description = "Mixin to add / call inheritable triggers";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  # nix-generate-from-cpan Makefile::DOM
  MakefileDOM = buildPerlPackage {
    pname = "Makefile-DOM";
    version = "0.008";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AG/AGENT/Makefile-DOM-0.008.tar.gz";
      hash = "sha256-31SZj0xSNImrDE2LL65EybsEqYxjp9UATQF55dz3WCQ=";
    };
    propagatedBuildInputs = [ Clone ListMoreUtils ParamsUtil ];
    meta = {
      description = "Simple DOM parser for Makefiles";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };


}); in

stdenvNoCC.mkDerivation rec {
  pname = "visualise-make";
  inherit (freetz) version meta;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    perl
  ];

  buildCommand = ''
    mkdir -p $out/bin
    cp ${freetz.src}/tools/visualise_make.pl $out/bin/visualise_make.pl
    cd $out/bin
    sed -i '1 i\#!/usr/bin/env perl' visualise_make.pl
    chmod +x visualise_make.pl
    patchShebangs .
    wrapProgram $out/bin/visualise_make.pl \
      --prefix PERL5LIB : "${with perlPackages; makePerlPath [
        GraphViz
        MakefileGraphViz
        IPCRun
        MakefileParser
        ListMoreUtils
        ExporterTiny
      ]}"
  '';
}
