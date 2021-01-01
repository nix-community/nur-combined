{ stdenv, lib, fetchzip, jdk, makeWrapper, installShellFiles, coreutils, gnused, bash }:
let
  pname = "micronaut-cli";
in rec {
  micronautGen = {version, src} : stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [ makeWrapper installShellFiles ];

    installPhase = ''
      runHook preInstall
      rm bin/mn.bat
      cp -r . $out
      wrapProgram $out/bin/mn \
        --set JAVA_HOME ${jdk} \
        --set PATH ${lib.makeBinPath [ gnused coreutils jdk bash ]}
      installShellCompletion --bash --name mn.bash bin/mn_completion
      runHook postInstall
    '';

    installCheckPhase = ''
      $out/bin/mn --version 2>&1 | grep -q "${version}"
    '';

    meta = with stdenv.lib; {
      description = "Modern, JVM-based, full-stack framework for building microservice applications";
      longDescription = ''
        Micronaut is a modern, JVM-based, full stack microservices framework
        designed for building modular, easily testable microservice applications.
        Reflection-based IoC frameworks load and cache reflection data for
        every single field, method, and constructor in your code, whereas with
        Micronaut, your application startup time and memory consumption are
        not bound to the size of your codebase.
      '';
      homepage = "https://micronaut.io/";
      license = licenses.asl20;
      platforms = platforms.all;
      maintainers = with maintainers; [ moaxcp ];
    };
  };

  micronaut-cli-2_2_2 = micronautGen rec {
    version = "2.2.2";
    src = fetchzip {
      url = "https://github.com/micronaut-projects/micronaut-starter/releases/download/v${version}/${pname}-${version}.zip";
      sha256 = "1jmasmf0hwra68x2dnw8mbdqsb0bll0ph8si7n6n5rd7kzihjjk0";
    };
  };
}
