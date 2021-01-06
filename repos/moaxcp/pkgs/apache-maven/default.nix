{ stdenv, lib, fetchurl, jdk, coreutils, makeWrapper }:
let
  pname = "apache-maven";
in rec {
  mavenGen = { version, src} : stdenv.mkDerivation {
    inherit pname version src;

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

    meta = with stdenv.lib; {
      description = "Build automation tool (used primarily for Java projects)";
      homepage = "http://maven.apache.org/";
      license = licenses.asl20;
      platforms = platforms.unix;
      maintainers = with maintainers; [ moaxcp ];
    };
  };

  apache-maven-3_5_4 = mavenGen rec {
    version = "3.5.4";
    src = fetchurl {
      url = "mirror://apache/maven/maven-3/${version}/binaries/${pname}-${version}-bin.tar.gz";
      sha256 = "sha256:0kd1jzlz3b2kglppi85h7286vdwjdmm7avvpwgppgjv42g4v2l6f";
    };
  };

  apache-maven-3_6_3 = mavenGen rec {
    version = "3.6.3";
    src = fetchurl {
      url = "mirror://apache/maven/maven-3/${version}/binaries/${pname}-${version}-bin.tar.gz";
      sha256 = "1i9qlj3vy4j1yyf22nwisd0pg88n9qzp9ymfhwqabadka7br3b96";
    };
  };
}