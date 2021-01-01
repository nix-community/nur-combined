{ stdenv, fetchurl, unzip, which, makeWrapper, jdk, coreutils, gawk }:

rec {
    groovyGen = {version, src} : stdenv.mkDerivation {
      pname = "groovy";
      inherit version src;
      dontBuild = true;

      buildInputs = [ unzip makeWrapper ];

      installPhase = ''
        mkdir -p $out
        mkdir -p $out/share/doc/groovy
        rm bin/*.bat
        mv {bin,conf,grooid,lib} $out
        mv {licenses,LICENSE,NOTICE} $out/share/doc/groovy

        sed -i 's#which#${which}/bin/which#g' $out/bin/startGroovy

        for p in grape java2groovy groovy{,doc,c,sh,Console}; do
          wrapProgram $out/bin/$p \
                --set JAVA_HOME "${jdk}" \
                --set PATH "${gawk}/bin:${coreutils}/bin:${jdk}/bin"
        done
      '';

      installCheckPhase = ''
        $out/bin/groovy --version 2>&1 | grep -q "${version}"
      '';

      meta = with stdenv.lib; {
        description = "An agile dynamic language for the Java Platform";
        homepage = http://groovy-lang.org/;
        license = licenses.asl20;
        maintainers = with maintainers; [ moaxcp ];
        platforms = with platforms; unix;
      };
    };

    groovy-4_0_0-alpha-2 = groovyGen rec {
        version = "4.0.0-alpha-2";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "1qwgsz5dvggrwhxm30l81pzv6h0swf5k35rhqicbkrmm2im19nd6";
        };
    };
}
