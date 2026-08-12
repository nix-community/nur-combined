{ stdenv, fetchzip, fetchMavenDeps, unzip, jre, maven, nixosTests
, version ? "git"
, srcUrl ? "https://github.com/jitsi/jitsi-videobridge/archive/389b69ff9c7a9ae73d1375584c3307ea11ced152.tar.gz"
, sha256 ? "1ggcbrh1vg3j2d4514rifkza7i2vr44dvdnvmzbsm3r586b97f6q"
, dependencies-sha256 ? "1kdpny5zg7vw0ns6z21bamzkcmw60jjni24zxxydlsgid7afp6na"
}:

let
  src = fetchzip {
    url = srcUrl;
    inherit sha256;
  };
  pname = "jitsi-videobridge";

  deps = fetchMavenDeps {
    inherit pname version src;
    sha256 = dependencies-sha256;
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ maven unzip ];
  buildInputs = [ jre ];

  buildPhase = ''
    cp -dpR "${deps}/.m2" ./
    chmod -R +w .m2
    mvn package --offline -Dmaven.repo.local="$(pwd)/.m2"
  '';

  installPhase = ''
    mkdir -p $out/{bin,share,etc/jitsi/videobridge}

    unzip target/jitsi-videobridge-*-archive.zip -d $out/share
    mv $out/share/jitsi-videobridge-* $out/share/jitsi-videobridge

    substituteInPlace $out/share/jitsi-videobridge/jvb.sh \
      --replace "exec java" "exec ${jre}/bin/java"

    mv $out/share/jitsi-videobridge/lib/logging.properties $out/etc/jitsi/videobridge/
    cp ${./logging.properties-journal} $out/etc/jitsi/videobridge/logging.properties-journal

    rm $out/share/jitsi-videobridge/jvb.bat
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
    platforms = platforms.linux;
  };
}
