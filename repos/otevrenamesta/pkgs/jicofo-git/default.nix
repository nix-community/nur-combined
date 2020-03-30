{ stdenv, fetchzip, fetchMavenDeps, unzip, maven, jre, nixosTests
, version ? "git"
, srcUrl ? "https://github.com/jitsi/jicofo/archive/f73164d58c820ece6be4fb5f536a1aa9b7f48603.tar.gz"
, sha256 ? "00iq120jn1n6ylpm7brw7dd4bkdag2ir368ky5nbjlrccskrrndy"
, dependencies-sha256 ? "08slx6i1i68f71h0zjvp6az9k5bh4av2bhlnzp076n56pszidagy"
}:

let
  src = fetchzip {
    url = srcUrl;
    inherit sha256;
  };
  pname = "jicofo";
  mavenFlags = "-Dmaven.test.skip=true";

  deps = fetchMavenDeps {
    inherit pname version src mavenFlags;
    sha256 = dependencies-sha256;
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ maven unzip ];

  buildPhase = ''
    cp -dpR "${deps}/.m2" ./
    chmod -R +w .m2
    mvn package --offline ${mavenFlags} -Dmaven.repo.local="$(pwd)/.m2"
  '';

  installPhase = ''
    mkdir -p $out/{bin,share,etc/jitsi/jicofo}

    unzip target/jicofo-*-archive.zip -d $out/share
    mv $out/share/jicofo-* $out/share/jicofo

    substituteInPlace $out/share/jicofo/jicofo.sh \
      --replace "exec java" "exec ${jre}/bin/java"

    mv $out/share/jicofo/lib/logging.properties $out/etc/jitsi/jicofo/
    rm $out/share/jicofo/jicofo.bat
    ln -s $out/share/jicofo/jicofo.sh $out/bin/jicofo
  '';

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
