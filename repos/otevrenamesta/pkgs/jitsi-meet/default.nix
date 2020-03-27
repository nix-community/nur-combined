{ pkgs, stdenv, fetchurl, nixosTests }:

stdenv.mkDerivation rec {
  pname = "jitsi-meet";
  # Upstream seems to publish source tarball for almost every git commit. Find the latest stable
  # version number by looking for the newest jitsi-meet-web DEB here: https://download.jitsi.org/stable/
  version = "3729";

  src = fetchurl {
    url = "https://download.jitsi.org/jitsi-meet/src/jitsi-meet-1.0.${version}.tar.bz2";
    sha256 = "0vl5hia571v293ha7kd7lr6pp0ncx9yras848p7ikvcjr6l6v312";
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
