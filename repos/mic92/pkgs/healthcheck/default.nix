{ stdenv, python3, fetchzip }:

stdenv.mkDerivation {
  pname = "healthcheck";
  version = "2020-02-22";
  src = fetchzip {
    url = "https://gist.github.com/Mic92/b2ebb4790db65d686d608c6875281dbf/archive/88af52b228bf49493aa7a9b261a1dc3eb9383f9b.tar.gz";
    sha256 = "0z5mdn74glq8p1wcvahagwb22wnk5w75ah0bn65xapd6jca7bdv7";
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
