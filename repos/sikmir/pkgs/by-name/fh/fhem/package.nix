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

  prePatch = ''
    touch Makefile.PL
  '';

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installFlags = [ "BINDIR=$(out)" ];

  postInstall = ''
    makeWrapper ${lib.getExe perlPackages.perl} $out/bin/fhem \
      --prefix PERL5LIB : "$out/FHEM:$PERL5LIB" \
      --add-flags "$out/fhem.pl"
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
