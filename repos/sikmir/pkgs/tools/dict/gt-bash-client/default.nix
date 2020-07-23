{ stdenv, sources }:
let
  pname = "gt-bash-client";
  date = stdenv.lib.substring 0 10 sources.gt-bash-client.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.gt-bash-client;

  installPhase = ''
    install -Dm755 translate.sh $out/bin/gt-bash-client
  '';

  meta = with stdenv.lib; {
    inherit (sources.gt-bash-client) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
