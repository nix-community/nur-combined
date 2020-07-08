{ stdenv, pcre, openssl, sources }:

stdenv.mkDerivation {
  pname = "csvtools";
  version = stdenv.lib.substring 0 7 sources.csvtools.rev;
  src = sources.csvtools;

  buildInputs = [ pcre ];

  makeFlags = [ "prefix=$(out)" ];
  enableParallelBuilding = true;

  doCheck = true;
  checkInputs = [ openssl ];

  preCheck = "patchShebangs .";

  preInstall = "mkdir -p $out/bin";

  meta = with stdenv.lib; {
    inherit (sources.csvtools) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}
