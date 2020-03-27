{ stdenv, fetchzip, jre, nixosTests }:

let
  pname = "jitsi-videobridge";
  version = "1132";
  src32 = fetchzip {
    url = "https://download.jitsi.org/${pname}/linux/${pname}-linux-x86-${version}.zip";
    sha256 = "1lk5nv6xnq9mww1xb8lwlw86fj1w2j83qx1z4fg8qvyi6cs2ablb";
  };
  src64 = fetchzip {
    url = "https://download.jitsi.org/${pname}/linux/${pname}-linux-x64-${version}.zip";
    sha256 = "0c62xp43agj4dgfwmjs7qr2gh24rgcm7398m05qbpggayc75dj1j";
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = if stdenv.isx86_64 then src64
     else if stdenv.isi686 then src32
     else throw "Unknown achitecture for ${pname}";

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    substituteInPlace jvb.sh \
      --replace "exec java" "exec ${jre}/bin/java"

    mkdir -p $out/{bin,share/jitsi-videobridge,etc/jitsi/videobridge}
    mv lib/logging.properties $out/etc/jitsi/videobridge/
    mv * $out/share/jitsi-videobridge/
    ln -s $out/share/jitsi-videobridge/jvb.sh $out/bin/jitsi-videobridge
  '';

  passthru.tests = {
    inherit (nixosTests) jitsi-meet;
  };

  meta = with stdenv.lib; {
    description = "A WebRTC compatible video router";
    longDescription = ''
      Jitsi Videobridge is an XMPP server component that allows for multiuser video communication.
      Unlike the expensive dedicated hardware videobridges, Jitsi Videobridge does not mix the video
      channels into a composite video stream, but only relays the received video channels to all call
      participants. Therefore, while it does need to run on a server with good network bandwidth,
      CPU horsepower is not that critical for performance.
    '';
    homepage = "https://github.com/jitsi/jitsi-videobridge";
    license = licenses.asl20;
    maintainers = with maintainers; [ mmilata ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
