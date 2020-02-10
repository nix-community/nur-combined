{ stdenv, pcre, openssl, csvtools }:

stdenv.mkDerivation rec {
  pname = "csvtools";
  version = stdenv.lib.substring 0 7 src.rev;
  src = csvtools;

  buildInputs = [ pcre ];

  makeFlags = [ "prefix=$(out)" ];
  enableParallelBuilding = true;

  doCheck = true;
  checkInputs = [ openssl ];

  preCheck = ''
    patchShebangs .
  '';

  preInstall = ''
    mkdir -p "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = csvtools.description;
    homepage = csvtools.homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
