{ lib, stdenv, makeWrapper, perl, AnyEvent, LinuxFD, CommonSense, pins
, SubExporter, DataOptList, ParamsUtil, SubInstall }:
stdenv.mkDerivation {
  pname = "urxvt-config-reload";
  version = "unstable-2019-10-11";

  src = pins.urxvt-config-reload.outPath;

  buildInputs = [ makeWrapper ];

  extraLibs = [
    AnyEvent LinuxFD CommonSense SubExporter
    # Not sure why the following are required, they're not on
    # propagatedBuildInputs of any of the deps...
    # TODO figure out a better way to handle this -- to determine and inject
    # runtime Perl dependency tree into calling urxvt
    DataOptList ParamsUtil SubInstall
  ];

  installPhase = ''
    mkdir -p $out/lib/urxvt/perl/
    cp config-reload $out/lib/urxvt/perl/
    cp config-print $out/lib/urxvt/perl/
  '';

  meta = {
    description     = ''
      A urxvt extension that allows reloading urxvt configuration at runtime by
      sending SIGHUP to the urxvt process.
    '';
    homepage        = "https://github.com/regnarg/urxvt-config-reload";
    maintainers     = with lib.maintainers; [ arobyn ];
  };
}
