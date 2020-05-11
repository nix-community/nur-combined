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
        mv {bin,conf,grooid,indy,lib} $out
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

    groovy-3_0_3 = groovyGen rec {
        version = "3.0.3";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "0xdm70b61pdj8z3g08az16y9b6cpz5hv7iwvwfyfyxrjdi47h419";
        };
    };

    groovy-3_0_2 = groovyGen rec {
        version = "3.0.2";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "1ddw3fqrmwh4w6z6xgck4jhmq33rwgbmpjw07g12ri1vgw4xks9w";
        };
    };

    groovy-2_5_11 = groovyGen rec {
        version = "2.5.11";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "1z8jmc0la4vcjlzcdn1nnharxpq9b3sv2q3ypbjw51nd03pc8qxr";
        };
    };

    groovy-2_5_10 = groovyGen rec {
        version = "2.5.10";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "0zqcvi423gkkns7jksna0pvkjihp79wnagyn5v3k76g5pkzzx3bk";
        };
    };

    groovy-2_4_19 = groovyGen rec {
        version = "2.4.19";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "127bz4z0rvz5q9crvm9nmh0b03lg54ysr5i9sp655vl173j7wl94";
        };
    };
}
