{ stdenv, sources }:

stdenv.mkDerivation {
  pname = "gt-bash-client-unstable";
  version = stdenv.lib.substring 0 10 sources.gt-bash-client.date;

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
