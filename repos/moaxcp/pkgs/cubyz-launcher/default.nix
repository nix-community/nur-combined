{stdenv, lib, fetchurl, jdk, coreutils, makeWrapper }:
  let pname = "cubyz-launcher";
in rec {
  cubyzGen = { version, src }: stdenv.mkDerivation {
    inherit pname version src;

    dontBuild = true;
    dontUnpack= true;

    buildInputs = [ jdk makeWrapper ];

    installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/lib
        cp ${src} $out/lib/launcher.jar

        echo "java -jar $out/lib/launcher.jar" > $out/bin/cubyz
        chmod ugo+x $out/bin/cubyz


      wrapProgram $out/bin/cubyz \
        --set JAVA_HOME ${jdk} \
        --set PATH ${lib.makeBinPath [ coreutils jdk ]}
    '';
  };

  cubyz-launcher-0_2 = cubyzGen rec {
    version = "0.2";
    src = fetchurl {
      url = "https://github.com/PixelGuys/Cubyz-Launcher/releases/download/0.2/launcher.jar";
      sha256 = "sha256:109l78gl02ss72m3fdywl9ipmh1ldmcsxzc4fpwivzkia3yck941";
    };
  };
}