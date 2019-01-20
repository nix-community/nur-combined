# Packaging heavily inspired by how hadoop is packaged
{ stdenv, fetchFromGitHub, maven, jre }:
let
  version = "2019-12-10";

  binary-distributon = stdenv.mkDerivation rec {
    name = "caas-${version}-bin";
    src = fetchFromGitHub {
      owner = "iNPUTmice";
      repo = "caas";
      sha256 = "02ap701mbamz6ym3m2qlw3nvi7wjs1h7gwrm5zam71c0g1ivic8k";
      rev = "3f1e91420340a7a404474412342e0e107363d4f3";
    };

    # perform fake build to make a fixed-output derivation of dependencies downloaded from maven central
    fetched-maven-deps = stdenv.mkDerivation {
      name = "caas-${version}-maven-deps";
      inherit src nativeBuildInputs;
      buildPhase = ''
        while mvn package -Dmaven.repo.local=$out/.m2 ${mavenFlags} -Dmaven.wagon.rto=5000; [ $? = 1 ]; do
          echo "timeout, restart maven to continue downloading"
        done
      '';
      # keep only *.{pom,jar,xml,sha1,so,dll,dylib} and delete all ephemeral files with lastModified timestamps inside
      installPhase = ''find $out/.m2 -type f -regex '.+\(\.lastUpdated\|resolver-status\.properties\|_remote\.repositories\)' -delete'';
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = "1hvpw66167pzslgprb6nz4im1f61g58vfbhvqhgixc3lvmhyxp9h";

    };

    nativeBuildInputs = [ maven ];

    mavenFlags = "-DskipTests -pl caas-annotations,caas-app";

    buildPhase = ''
      # 'maven.repo.local' must be writable
      mvn package --offline -Dmaven.repo.local=$(cp -dpR ${fetched-maven-deps}/.m2 ./ && chmod +w -R .m2 && pwd)/.m2 ${mavenFlags}
    '';

    installPhase = ''
      mkdir -p $out
      mv caas-app/target/caas-app.jar $out
    '';
  };
in

stdenv.mkDerivation rec {
  name = "caas-${version}";

  src = binary-distributon;

  installPhase = ''
    mkdir -p $out/bin{,.wrapped}
    cp -dpR * $out/bin.wrapped/

    cat > $out/bin/caas <<EOF
    #! $shell
    export JAVA_HOME=${jre}
    exec ${jre}/bin/java -jar $out/bin.wrapped/caas-app.jar "\$@"
    EOF
    chmod +x $out/bin/*
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/iNPUTmice/caas;
    description = "XMPP Compliance Tester";
    license = licenses.bsd3;
    maintainers = with maintainers; [ johnazoidberg ];
  };
}
