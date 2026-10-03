{
  lib,
  stdenv,
  fetchurl,
  perlPackages,
  makeWrapper,
}:

perlPackages.buildPerlPackage rec {
  pname = "fhem";
  version = "6.4";

  src = fetchurl {
    url = "https://fhem.de/fhem-${version}.tar.gz";
    hash = "sha256-AGL2GKV5ttv5s9wsJPsjV+iHYeyXtGABuERAwJwMsRc=";
  };

  postPatch = ''
    touch Makefile.PL
    substituteInPlace fhem.pl \
      --replace-fail 'global modpath .' "global modpath $out/opt/fhem"
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ perlPackages.DeviceSerialPort ];

  dontBuild = true;

  installFlags = [ "BINDIR=$(out)/opt/fhem" ];

  postInstall = ''
    makeWrapper ${lib.getExe perlPackages.perl} $out/bin/fhem \
      --prefix PERL5LIB : "$out/opt/fhem/FHEM:$PERL5LIB" \
      --add-flags "$out/opt/fhem/fhem.pl"
  '';

  outputs = [ "out" ];

  meta = {
    homepage = "https://fhem.de";
    description = "FHEM (TM) is a GPL'd perl server for house automation";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
  };
}
