{ stdenv, python3, fetchzip }:

stdenv.mkDerivation {
  pname = "healthcheck";
  version = "2020-02-20";
  src = fetchzip {
    url = "https://gist.github.com/Mic92/b2ebb4790db65d686d608c6875281dbf/archive/c608c9ba0a1b2e210e24b48972736f99debe471c.tar.gz";
    sha256 = "0aj731i3vxxb1xbfvb9h4j5qp4pdrn67rh8mi4w4rb7jw6v0lh7a";
  };
  buildInputs = [ python3 ];
  installPhase = ''
    install -D -m 755 healthcheck.py $out/bin/healthcheck
  '';
  meta = with stdenv.lib; {
    description = "Healtcheck for icingamaster.bsd.services";
    homepage = https://gist.github.com/Mic92/b2ebb4790db65d686d608c6875281dbf;
    license = licenses.mit;
    platforms = platforms.all;
  };
}
