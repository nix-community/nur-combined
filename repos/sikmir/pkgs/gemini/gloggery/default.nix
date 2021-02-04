{ lib, stdenv, go, sources }:

stdenv.mkDerivation {
  pname = "gloggery-unstable";
  version = lib.substring 0 10 sources.gloggery.date;

  src = sources.gloggery;

  nativeBuildInputs = [ go ];

  makeFlags = [ "GOCACHE=$(TMPDIR)/go-cache" "HOME=$(out)" ];

  preInstall = "install -dm755 $out/{bin,share}";

  postInstall = "mv $out/.gloggery $out/share/glogger";

  meta = with lib; {
    inherit (sources.gloggery) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
