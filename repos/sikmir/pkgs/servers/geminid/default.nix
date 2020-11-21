{ stdenv, libconfig, file, openssl, flex, sources }:

stdenv.mkDerivation {
  pname = "geminid";
  version = stdenv.lib.substring 0 10 sources.geminid.date;

  src = sources.geminid;

  nativeBuildInputs = [ flex ];

  buildInputs = [ libconfig file openssl.dev ];

  makeFlags = [ "geminid" "CC=cc" "LEX=flex" ];

  installPhase = "install -Dm755 geminid -t $out/bin";

  meta = with stdenv.lib; {
    inherit (sources.geminid) description homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
