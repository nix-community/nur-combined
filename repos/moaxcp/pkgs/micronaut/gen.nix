{stdenv, lib, jdk, gnused, coreutils, bash, makeWrapper, installShellFiles, pname, version, src} : stdenv.mkDerivation {
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

    meta = with lib; {
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
}