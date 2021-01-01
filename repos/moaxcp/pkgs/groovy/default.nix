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

    groovy-4_0_0-alpha-2 = groovyGen rec {
        version = "4.0.0-alpha-2";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "1qwgsz5dvggrwhxm30l81pzv6h0swf5k35rhqicbkrmm2im19nd6";
        };
    };

    groovy-3_0_7 = groovyGen rec {
        version = "3.0.7";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "1xdpjqx7qaq0syw448b32q36g12pgh1hn6knyqi3k5isp0f09qmr";
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

    groovy-2_5_14 = groovyGen rec {
        version = "2.5.14";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "16cn3knsykc3rpjr6pli4f5ljhklzk9yr2y41k8jm3sfkalpda3i";
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

    groovy-2_4_21 = groovyGen rec {
        version = "2.4.21";
        src = fetchurl {
            url = "https://dl.bintray.com/groovy/maven/apache-groovy-binary-${version}.zip";
            sha256 = "0h4g0l3nklp2nddnq2l41zp1jg425ld120mi0lbj8jh5map5j3rg";
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
