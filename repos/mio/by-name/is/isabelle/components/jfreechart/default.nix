{
  lib,
  fetchurl,
  fetchFromGitHub,
  jdk,
  maven,
  addSettings,
}:

let
  version = "1.5.3";

  runtimeArchive = fetchurl {
    url = "https://isabelle.in.tum.de/components/jfreechart-${version}.tar.gz";
    hash = "sha256-39Un5RC9xi6252ZsPaUm2SDr3GaFc1KLvEJ+cphwEbs=";
  };

  package = maven.buildMavenPackage {
    pname = "jfreechart";
    inherit version;

    src = fetchFromGitHub {
      owner = "jfree";
      repo = "jfreechart";
      tag = "v${version}";
      hash = "sha256-BwPECuVa1zVQhnLTf7YGZYobFbB3ffAqlarCcIcJH/0=";
    };

    buildOffline = true;
    mvnJdk = jdk;
    mvnHash = "sha256-xHKNcpOLKC3MWxnOL2XPV2GdmClcbcwHtImJ1FDa2jE=";
    mvnParameters = "-DskipTests package";

    nativeBuildInputs = [ jdk ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      install -m644 target/jfreechart-${version}.jar $out/lib/
      mkdir -p lib
      tar -xzf ${runtimeArchive} --wildcards '*/lib/iText-2.1.5.jar' --strip-components=1
      install -m644 lib/iText-2.1.5.jar $out/lib/

      runHook postInstall
    '';
  };
in
addSettings package (finalAttrs: ''
  JFREECHART_HOME="${finalAttrs.finalPackage}"

  classpath "$JFREECHART_HOME/lib/iText-2.1.5.jar"
  classpath "$JFREECHART_HOME/lib/jfreechart-${version}.jar"
'')
