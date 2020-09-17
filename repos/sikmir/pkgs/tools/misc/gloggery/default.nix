{ stdenv, go, sources }:
let
  pname = "gloggery";
  date = stdenv.lib.substring 0 10 sources.gloggery.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.gloggery;

  nativeBuildInputs = [ go ];

  makeFlags = [ "GOCACHE=$(TMPDIR)/go-cache" "HOME=$(out)" ];

  preInstall = "install -dm755 $out/{bin,share}";

  postInstall = "mv $out/.gloggery $out/share/glogger";

  meta = with stdenv.lib; {
    inherit (sources.gloggery) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
