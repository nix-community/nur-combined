{ stdenv, fetchurl, perlPackages, ncbi_blast, parallel, bedtools, prank, mcl, mafft, cd-hit, makeWrapper }:
with perlPackages; 
rec {
  inherit perl;

  ArrayUtils = buildPerlPackage {
    pname = "Array-Utils";
    version = "0.5";
    src = fetchurl {
      url = "mirror://cpan/authors/id/Z/ZM/ZMIJ/Array/Array-Utils-0.5.tar.gz";
      sha256 = "89dd1b7fcd9b4379492a3a77496e39fe6cd379b773fd03a6b160dd26ede63770";
    };
    meta = {
      description = "Small utils for array manipulation";
    };
  };

  BioDBEMBL = buildPerlPackage {
    pname = "Bio-DB-EMBL";
    version = "1.7.4";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/Bio-DB-EMBL-1.7.4.tar.gz";
      sha256 = "fce080c4b3db7bcc529fd0cf0d29700d0b86ef8bbe7f77ad87f429a3ae7e1a27";
    };
    buildInputs = [ TestMost TestDifferences TestWarn TestException TestDeep TestRequiresInternet ];
    propagatedBuildInputs = [ BioPerl ];
    meta = {
      homepage = https://metacpan.org/release/Bio-DB-EMBL;
      description = "Database object interface for EMBL entry retrieval";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  BioRoary = 
    let 
      external = [ncbi_blast parallel bedtools prank mcl mafft cd-hit];
    in buildPerlPackage {
    pname = "Bio-Roary";
    version = "3.13.0";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AJ/AJPAGE/Bio-Roary-3.13.0.tar.gz";
      sha256 = "4eb61cefaf9bf9a0cfd5460a7d0fa0280d9b00484018421a23325a9f25f9133f";
    };

    patches = [ ./test_data_diff_fix.patch ];

    prePatch = ''
      patchShebangs ./t/bin ./bin
    '';

    buildInputs = [ EnvPath TestWarn TestDeep TestException TestDifferences TestFiles TestMost TestOutput makeWrapper ] ++ external;

    propagatedBuildInputs = [ ArrayUtils BioPerl BioProcedural DigestMD5File ExceptionClass FileFindRule FileGrep FileSlurper FileWhich Graph GraphReadWrite LogLog4perl Moose PerlIOutf8_strict TextCSV ];

    postFixup = ''
      wrapProgram $out/bin/roary --prefix PATH : ${stdenv.lib.makeBinPath external}
    '';

    meta = {
      homepage = http://www.sanger.ac.uk/;
      description = "Create a pan genome";
      license = stdenv.lib.licenses.gpl3Plus;
    };
  };

  TestFiles = buildPerlPackage {
    pname = "Test-Files";
    version = "0.14";
    src = fetchurl {
      url = "mirror://cpan/authors/id/P/PH/PHILCROW/Test-Files-0.14.tar.gz";
      sha256 = "96ceabf035243048f591bfe135ed3f7619b63b25597a92658807dbffa21fc3fe";
    };
    propagatedBuildInputs = [ AlgorithmDiff TextDiff ];
  };

  BioPerl = buildPerlPackage rec {
    pname = "BioPerl";
    version = "1.7.7";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/${pname}-${version}.tar.gz";
      sha256 = "730e2bd38b7550bf6bbd5bca50d019a70cca514559702c1389d770ff69cff1bb";
    };
    buildInputs = [ TestMemoryCycle TestWeaken TestWarn TestDeep 
      TestDifferences TestException ];
    propagatedBuildInputs = [ DBFile DataStag Error Graph HTTPMessage IOString 
      IOStringy IPCRun LWP ListMoreUtils ModuleBuild SetScalar TestMost 
      TestRequiresInternet URI XMLDOM XMLDOMXPath XMLLibXML XMLSAX XMLSAXBase 
      XMLSAXWriter XMLTwig XMLWriter YAML libxml_perl ];
    meta = {
      homepage = https://metacpan.org/release/BioPerl;
      description = "Perl modules for biology";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  BioProcedural = buildPerlPackage {
    pname = "Bio-Procedural";
    version = "1.7.4";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/Bio-Procedural-1.7.4.tar.gz";
      sha256 = "d2bd9cfbb091eee2d80ed6cf812ac3813b1c8a1aaca20671037f5f225d31d1da";
    };

    buildInputs = [ TestWarn TestDeep TestDifferences TestException ];

    NO_NETWORK_TESTING = 1;

    propagatedBuildInputs = [ BioDBRefSeq BioDBSwissProt BioPerl BioToolsRunRemoteBlast LWPProtocolhttps ];
    meta = {
      homepage = https://metacpan.org/release/Bio-Procedural;
      description = "Simple low-dependency procedural interfaces to BioPerl";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  FileGrep = buildPerlPackage {
    pname = "File-Grep";
    version = "0.02";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MN/MNEYLON/File-Grep-0.02.tar.gz";
      sha256 = "462e15274eb6278521407ea302d9eea7252cd44cab2382871f7de833d5f85632";
    };
    meta = {
      license = stdenv.lib.licenses.artistic1;
    };
  };

  GraphReadWrite = buildPerlPackage {
    pname = "Graph-ReadWrite";
    version = "2.09";
    src = fetchurl {
      url = "mirror://cpan/authors/id/N/NE/NEILB/Graph-ReadWrite-2.09.tar.gz";
      sha256 = "b01ef06ce922eea12d5ce614d63ddc5f3ee7ad0d05f9577051d3f87a89799a4a";
    };
    propagatedBuildInputs = [ Graph ParseYapp XMLParser XMLWriter ];
    meta = {
      homepage = https://github.com/neilb/Graph-ReadWrite;
      description = "Modules for reading and writing directed graphs";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestWeaken = buildPerlPackage {
    pname = "Test-Weaken";
    version = "3.022000";
    src = fetchurl {
      url = "mirror://cpan/authors/id/K/KR/KRYDE/Test-Weaken-3.022000.tar.gz";
      sha256 = "2631a87121310262e0e96107a6fa0ed69487b7701520773bee5fa9accc295f5b";
    };
    meta = {
      description = "Test that freed memory objects were, indeed, freed";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  BioDBNCBIHelper = buildPerlPackage {
    pname = "Bio-DB-NCBIHelper";
    version = "1.7.6";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/Bio-DB-NCBIHelper-1.7.6.tar.gz";
      sha256 = "6475fef8475e9491fec352b4fe3a6249be7b0bee92e7bad62c3f81ca31e3bcc7";
    };
    buildInputs = [ TestException TestMost TestRequiresInternet ];
    propagatedBuildInputs = [ BioASN1EntrezGene BioPerl CGI CacheCache HTTPMessage LWP LWPProtocolhttps URI XMLTwig ];
    meta = {
      homepage = https://metacpan.org/release/Bio-DB-NCBIHelper;
      description = "A collection of routines useful for queries to NCBI databases";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  DataStag = buildPerlPackage rec {
    pname = "Data-Stag";
    version = "0.14";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CM/CMUNGALL/${pname}-${version}.tar.gz";
      sha256 = "4ab122508d2fb86d171a15f4006e5cf896d5facfa65219c0b243a89906258e59";
    };
    propagatedBuildInputs = [ IOString ];
    meta = {
      description = "Structured Tags";
    };
  };

  XMLDOMXPath = buildPerlPackage rec {
    pname = "XML-DOM-XPath";
    version = "0.14";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MI/MIROD/${pname}-${version}.tar.gz";
      sha256 = "0173a74a515211997a3117a47e7b9ea43594a04b865b69da5a71c0886fa829ea";
    };
    patchPhase = ''
      substituteInPlace t/test_non_ascii.t \
        --replace "use encoding 'utf8';" "use utf8;"
    '';
    propagatedBuildInputs = [ XMLDOM XMLXPathEngine ];
    meta = {
      description = "Perl extension to add XPath support to XML::DOM, using XML::XPath engine";
    };
  };

  BioSearchIOhmmer = buildPerlPackage {
    pname = "Bio-SearchIO-hmmer";
    version = "1.7.3";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/Bio-SearchIO-hmmer-1.7.3.tar.gz";
      sha256 = "686152f8ce7c611d27ee35ac002ecc309f6270e289a482993796a23bb5388246";
    };
    buildInputs = with perlPackages; [ TestDeep TestException TestWarn TestDifferences ];
    propagatedBuildInputs = with perlPackages; [ BioPerl IOString ];
    meta = {
      homepage = https://metacpan.org/release/Bio-SearchIO-hmmer;
      description = "A parser for HMMER2 and HMMER3 output (hmmscan, hmmsearch, hmmpfam)";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  BioDBRefSeq = buildPerlPackage {
    pname = "Bio-DB-RefSeq";
    version = "1.7.4";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/Bio-DB-RefSeq-1.7.4.tar.gz";
      sha256 = "f3f4e44827cc86af9c2486c63935474951fde7f8647d2edc0c3a18c23640feab";
    };
    buildInputs = [ TestNeeds TestRequiresInternet ];
    propagatedBuildInputs = [ BioPerl ];
    meta = {
      homepage = https://metacpan.org/release/Bio-DB-RefSeq;
      description = "Database object interface for RefSeq retrieval";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  BioDBSwissProt = buildPerlPackage {
    pname = "Bio-DB-SwissProt";
    version = "1.7.4";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/Bio-DB-SwissProt-1.7.4.tar.gz";
      sha256 = "8245e437ed59a389b2db3e961a1361559eef7bcca873c77d8588d2a64ed9b170";
    };
    buildInputs = [ TestNeeds TestRequiresInternet ];
    propagatedBuildInputs = [ BioPerl HTTPMessage ];
    meta = {
      homepage = https://metacpan.org/release/Bio-DB-SwissProt;
      description = "Database object interface to SwissProt retrieval";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  BioToolsRunRemoteBlast = buildPerlPackage {
    pname = "Bio-Tools-Run-RemoteBlast";
    version = "1.7.3";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/Bio-Tools-Run-RemoteBlast-1.7.3.tar.gz";
      sha256 = "b86901f48c9b92fa708d33443a81cfebe9a2be28e4af2424a9b9b60f12c43768";
    };
    propagatedBuildInputs = [ BioPerl HTTPMessage IOString LWP ];
    meta = {
      homepage = https://metacpan.org/release/Bio-Tools-Run-RemoteBlast;
      description = "Object for remote execution of the NCBI Blast via HTTP";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ParseYapp = buildPerlPackage {
    pname = "Parse-Yapp";
    version = "1.21";
    src = fetchurl {
      url = "mirror://cpan/authors/id/W/WB/WBRASWELL/Parse-Yapp-1.21.tar.gz";
      sha256 = "3810e998308fba2e0f4f26043035032b027ce51ce5c8a52a8b8e340ca65f13e5";
    };
    meta = {
      license = stdenv.lib.licenses.artistic1;
    };
  };
}
