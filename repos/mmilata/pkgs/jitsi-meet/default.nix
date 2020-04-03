{ pkgs, stdenv, fetchurl, nixosTests }:

stdenv.mkDerivation rec {
  pname = "jitsi-meet";
  version = "3962";

  src = fetchurl {
    url = "https://download.jitsi.org/jitsi-meet/src/jitsi-meet-1.0.${version}.tar.bz2";
    sha256 = "1rqpn3as4x9mk6sbr2mcjiis28iqc3ablmxg7i1b5hakqkid764i";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir $out
    mv * $out/
  '';

  passthru.tests = {
    inherit (nixosTests) jitsi-meet;
  };

  meta = with stdenv.lib; {
    description = "Secure, Simple and Scalable Video Conferences";
    longDescription = ''
      Jitsi Meet is an open-source (Apache) WebRTC JavaScript application that uses Jitsi Videobridge
      to provide high quality, secure and scalable video conferences.
    '';
    homepage = "https://github.com/jitsi/jitsi-meet";
    license = licenses.asl20;
    maintainers = with maintainers; [ mmilata ];
    platforms = platforms.all;
  };
}
