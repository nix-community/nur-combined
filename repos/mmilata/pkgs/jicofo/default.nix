{ pkgs, stdenv, fetchurl, dpkg, jre_headless, nixosTests }:

let
  pname = "jicofo";
  version = "1.0-541";
  src = fetchurl {
    url = "https://download.jitsi.org/stable/${pname}_${version}-1_all.deb";
    sha256 = "0s45bjsja2nkjhjcd2gx6hbby49v1d6r6553l6jfainycf6dh7xy";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    substituteInPlace usr/share/jicofo/jicofo.sh \
      --replace "exec java" "exec ${jre_headless}/bin/java"

    mkdir -p $out/{share,bin}
    mv usr/share/jicofo $out/share/
    mv etc $out/
    cp ${./logging.properties-journal} $out/etc/jitsi/jicofo/logging.properties-journal
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
    platforms = platforms.linux;
  };
}
