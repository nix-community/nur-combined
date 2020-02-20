{ stdenv, python3, fetchzip }:

stdenv.mkDerivation {
  pname = "healthcheck";
  version = "2020-02-20";
  src = fetchzip {
    url = "https://gist.github.com/Mic92/b2ebb4790db65d686d608c6875281dbf/archive/9c6e4dbab06fbc2ab587cea94ec0930918a760b1.tar.gz";
    sha256 = "0xx529bv915dmyfnh7h8c39k6xkz6mgxlah6fvg59hm9ibidairz";
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
