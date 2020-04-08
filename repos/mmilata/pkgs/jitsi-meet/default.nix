{ pkgs, stdenv, fetchurl, nixosTests }:

stdenv.mkDerivation rec {
  pname = "jitsi-meet";
  version = "1.0.3969";

  src = fetchurl {
    url = "https://download.jitsi.org/jitsi-meet/src/jitsi-meet-${version}.tar.bz2";
    sha256 = "0s6glh655ifw67gamj533c0hai4c023a5qaxckyf3i1rbsazm6f8";
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
