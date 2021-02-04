{ lib, stdenv, pcre, openssl, sources }:

stdenv.mkDerivation {
  pname = "csvtools";
  version = lib.substring 0 10 sources.csvtools.date;

  src = sources.csvtools;

  buildInputs = [ pcre ];

  makeFlags = [ "prefix=$(out)" ];
  enableParallelBuilding = true;

  doCheck = true;
  checkInputs = [ openssl ];

  preCheck = "patchShebangs .";

  preInstall = "mkdir -p $out/bin";

  meta = with lib; {
    inherit (sources.csvtools) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
