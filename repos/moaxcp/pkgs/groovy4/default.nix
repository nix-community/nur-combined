{ lib, stdenv, fetchurl, unzip, which, makeWrapper, jdk, coreutils, gawk }:

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

      meta = with lib; {
        description = "An agile dynamic language for the Java Platform";
        homepage = http://groovy-lang.org/;
        license = licenses.asl20;
        maintainers = with maintainers; [ moaxcp ];
        platforms = with platforms; unix;
      };
    };

    groovy-4_0_0 = groovyGen rec {
        version = "4.0.0";
        src = fetchurl {
            url = "https://groovy.jfrog.io/artifactory/dist-release-local/groovy-zips/apache-groovy-binary-${version}.zip";
            sha256 = "sha256:1y8dwgmsv4lgkpi2dxlpwqp26viahfw0r85fqz2l37qnkkv8lnxx";
        };
    };

    groovy-4_0_0-rc-1 = groovyGen rec {
        version = "4.0.0-rc-1";
        src = fetchurl {
            url = "https://groovy.jfrog.io/artifactory/dist-release-local/groovy-zips/apache-groovy-binary-${version}.zip";
            sha256 = "sha256:1ahrfnlfdqdz3m1fwxjnfl99qkx5xc7jfzfnrm9c7d387zxqjvbk";
        };
    };
}
