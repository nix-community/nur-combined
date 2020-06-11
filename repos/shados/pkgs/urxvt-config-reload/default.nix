{ stdenv, fetchFromGitHub, makeWrapper, perl, AnyEvent, LinuxFD, CommonSense
, SubExporter, DataOptList, ParamsUtil, SubInstall }:
stdenv.mkDerivation {
  name = "urxvt-config-reload";

  src = fetchFromGitHub {
    owner   = "regnarg";
    repo    = "urxvt-config-reload";
    rev     = "7e26031a6dfcd22d3747c256899a600d509ae9b4";
    sha256  = "0zkinp5a9llxq63ssdk9ym20sdv9q2mgjz1x5z5a32gbwcz9ggfa";
  };

  patches = [
    ./border-color.patch
  ];

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
    maintainers     = with stdenv.lib.maintainers; [ arobyn ];
  };
}
