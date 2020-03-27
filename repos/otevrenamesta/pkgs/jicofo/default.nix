{ pkgs, stdenv, fetchurl, dpkg, jre_headless, nixosTests }:

let
  pname = "jicofo";
  version = "508";
  src32 = fetchurl {
    url = "https://download.jitsi.org/stable/${pname}_1.0-${version}-1_i386.deb";
    sha256 = "1gqrrwf8kacl4rs0ckrpxbg1clbj4y7fyrqks09z0zv7i7kdyhdd";
  };
  src64 = fetchurl {
    url = "https://download.jitsi.org/stable/${pname}_1.0-${version}-1_amd64.deb";
    sha256 = "16qwja138p8ygxg491gzfqpy0ihs2lkpq5221n5sdiq5wh8cq8dm";
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = if stdenv.isx86_64 then src64
     else if stdenv.isi686 then src32
     else throw "Unknown achitecture for ${pname}";

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    dpkg -x $src .

    substituteInPlace usr/share/jicofo/jicofo.sh \
      --replace "exec java" "exec ${jre_headless}/bin/java"

    mkdir -p $out/{share,bin}
    mv usr/share/jicofo $out/share/
    mv etc $out/
    ln -s $out/share/jicofo/jicofo.sh $out/bin/jicofo
  '';

  nativeBuildInputs = [ dpkg ];

  passthru.tests = {
    inherit (nixosTests) jitsi-meet;
  };

  meta = with stdenv.lib; {
    description = "A server side focus component used in Jitsi Meet conferences";
    longDescription = ''
      JItsi COnference FOcus is a server side focus component used in Jitsi Meet conferences.
    '';
    homepage = "https://github.com/jitsi/jicofo";
    license = licenses.asl20;
    maintainers = with maintainers; [ mmilata ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
