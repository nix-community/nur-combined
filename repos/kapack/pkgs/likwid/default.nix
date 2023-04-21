{ stdenv, lib, fetchurl, perl }:

stdenv.mkDerivation rec {
  pname = "likwid";
  version = "5.2.1";

  src = fetchurl {
    url = "https://github.com/RRZE-HPC/likwid/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-G45mjaEX8kMCo0RZYzbsosadK8L0n6IoykHqBoj2y8I=";
  };

  buildInputs = [ perl ];

  hardeningDisable = [ "format" ];

  preBuild=''
 	substituteInPlace config.mk --replace 'PREFIX ?= /usr/local' "PREFIX ?= $out" --replace "ACCESSMODE = accessdaemon" "ACCESSMODE = perf_event"
 	substituteInPlace perl/gen_events.pl --replace '/usr/bin/env perl' '${perl}/bin/perl'
 	substituteInPlace bench/perl/generatePas.pl --replace '/usr/bin/env perl' '${perl}/bin/perl'
 	substituteInPlace bench/perl/AsmGen.pl --replace '/usr/bin/env perl' '${perl}/bin/perl'
	substituteInPlace Makefile --replace '@install -m 4755 $(INSTALL_CHOWN)' '#@install -m 4755 $(INSTALL_CHOWN)'
  '';

  meta = with lib; {
    description = ''
	Likwid is a simple to install and use toolsuite of command line applications and a library for performance oriented programmers. It works for Intel, AMD, ARMv8 and POWER9 processors on the Linux operating system. There is additional support for Nvidia GPUs. There is support for ARMv7 and POWER8 but there is currently no test machine in our hands to test them properly.
    '';
    homepage    = "https://hpc.fau.de/research/tools/likwid/";
    platforms   = platforms.unix;
  };
}
