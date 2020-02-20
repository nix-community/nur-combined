{ stdenv, python3, fetchzip }:

stdenv.mkDerivation {
  pname = "healthcheck";
  version = "2020-02-20";
  src = fetchzip {
    url = "https://gist.github.com/Mic92/b2ebb4790db65d686d608c6875281dbf/archive/6e53d82b7399f1863f98b5d834c69be227ef9854.tar.gz";
    sha256 = "0yxwlrazbl4lipgh5gcd1kcgxfiq4i8yxr6xhqcm92y68fwfckjh";
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
