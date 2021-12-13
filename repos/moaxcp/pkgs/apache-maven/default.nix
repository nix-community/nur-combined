{ stdenv, lib, fetchurl, jdk, coreutils, makeWrapper }:
let
  mavenGen = { version, src} : stdenv.mkDerivation {
    pname = "apache-maven";
    inherit version src;
    dontBuild = true;

    buildInputs = [ jdk makeWrapper ];

    installPhase = ''
      mkdir -pv $out
      cp -rv * $out

      wrapProgram $out/bin/mvn \
        --set JAVA_HOME ${jdk} \
        --set PATH ${lib.makeBinPath [ coreutils jdk ]}
      wrapProgram $out/bin/mvnDebug \
        --set JAVA_HOME ${jdk} \
        --set PATH ${lib.makeBinPath [ coreutils jdk ]}
    '';

    installCheckPhase = ''
      $out/bin/mvn --version 2>&1 | grep -q "Apache Maven ${version}"
    '';

    meta = with lib; {
      description = "Build automation tool (used primarily for Java projects)";
      homepage = "http://maven.apache.org/";
      license = licenses.asl20;
      platforms = platforms.unix;
      maintainers = with maintainers; [ moaxcp ];
    };
  };
in {
  apache-maven-3_5_4 = mavenGen rec {
    version = "3.5.4";
    src = fetchurl {
      url = "mirror://apache/maven/maven-3/${version}/binaries/apache-maven-${version}-bin.tar.gz";
      sha256 = "sha256:0kd1jzlz3b2kglppi85h7286vdwjdmm7avvpwgppgjv42g4v2l6f";
    };
  };

  apache-maven-3_6_3 = mavenGen rec {
    version = "3.6.3";
    src = fetchurl {
      url = "mirror://apache/maven/maven-3/${version}/binaries/apache-maven-${version}-bin.tar.gz";
      sha256 = "1i9qlj3vy4j1yyf22nwisd0pg88n9qzp9ymfhwqabadka7br3b96";
    };
  };

  apache-maven-3_8_4 = mavenGen rec {
    version = "3.8.4";
    src = fetchurl {
      url = "mirror://apache/maven/maven-3/${version}/binaries/apache-maven-${version}-bin.tar.gz";
      sha256 = "sha256:0g7iz7b66j4z9r5v3rrhv6my945pcf85mvsvqbyj1fr7ji8rrp1c";
    };
  };
}