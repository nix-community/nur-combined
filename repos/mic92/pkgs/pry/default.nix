{ buildPerlPackage, fetchurl, perlPackages }:

with perlPackages;

let
  ConfigINIReaderOrdered = buildPerlPackage rec {
    name = "Config-INI-Reader-Ordered-0.020";
    src = fetchurl {
      url = "mirror://cpan/authors/id/R/RJ/RJBS/${name}.tar.gz";
      sha256 = "07gpp6q3l4i84vqx49f5fn626dwrxy07ld7j2zgaxrj8za54b12r";
    }; 
    propagatedBuildInputs = [ ConfigINI ];
  };

  DevelLexAlias = buildPerlPackage rec {
    name = "Devel-LexAlias-0.05";
    src = fetchurl {
      url = "mirror://cpan/authors/id/R/RC/RCLAMP/${name}.tar.gz";
      sha256 = "0wpfpjqlrncslnmxa37494sfdy0901510kj2ds2k6q167vadj2jy";
    }; 
    propagatedBuildInputs = [ DevelCaller ];
  };

  Reply = buildPerlPackage rec {
    name = "Reply-0.42";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DO/DOY/${name}.tar.gz";
      sha256 = "1wkrmc1ksy4zdribj305mmwmsvc2x9283979qh8awm3slx2jmnja";
    }; 
    propagatedBuildInputs = [
      ConfigINIReaderOrdered DevelLexAlias EvalClosure
      FileHomeDir ModuleRuntime PackageStash PadWalker TryTiny TermReadLineGnu
    ];
  };
in buildPerlPackage rec {
  name = "Pry-0.003001";
  src = fetchurl {
    url = "mirror://cpan/authors/id/T/TO/TOBYINK/${name}.tar.gz";
    sha256 = "1hqh7b5846avg2sar0im3mxxibi1nn8fr0rs0fps3asjjfaxby5q";
  }; 
  propagatedBuildInputs = [ 
    DevelStackTrace ExporterTiny PadWalker Reply BKeywords
  ];
  meta = with stdenv.lib; {
    description = "Intrude on your code";
    homepage = https://metacpan.org/pod/Pry;
    license = licenses.artistic1;
  };
}
