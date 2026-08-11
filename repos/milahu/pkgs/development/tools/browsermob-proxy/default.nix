# based on https://ryantm.github.io/nixpkgs/languages-frameworks/maven/

{
  lib,
  stdenv,
  fetchFromGitHub,
  jdk8,
  jre8,
  maven,
  javaPackages,
  makeWrapper,
}:

let
  # https://github.com/lightbody/browsermob-proxy/issues/878
  jdk = jdk8;
  jre = jre8;
in

maven.buildMavenPackage rec {
  pname = "browsermob-proxy";
  version = "2.1.4";

  src = fetchFromGitHub {
    owner = "lightbody";
    repo = "browsermob-proxy";
    rev = "browsermob-proxy-${version}";
    hash = "sha256-KhT80NFaf/74v4ex4+u09eP9HKBwGYvQ7ftoePdr7mA=";
  };

  mvnHash = "sha256-tmyZjcFSa2UwVwAvcek6a2QBp2HTAKKMJqhmgsOyqZc=";

  mvnJdk = jdk8;

  mvnParameters = "-Dmaven.test.skip";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib
    cp browsermob-dist/target/browsermob-dist-${version}.jar $out/lib
    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/browsermob-proxy \
      --add-flags "-jar $out/lib/browsermob-dist-${version}.jar"
  '';

  meta = {
    description = "A free utility to help web developers watch and manipulate network traffic from their AJAX applications";
    homepage = "https://github.com/lightbody/browsermob-proxy";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "browsermob-proxy";
    platforms = lib.platforms.all;
  };
}
