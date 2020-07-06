{ stdenv, lib, coursier, jdk, jre, python, makeWrapper }:

let
  baseName = "metals";
  version = "0.9.1";
  deps = stdenv.mkDerivation {
    name = "${baseName}-deps-${version}";
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${coursier}/bin/coursier fetch org.scalameta:metals_2.12:${version} \
        -r bintray:scalacenter/releases \
        -r sonatype:snapshots > deps
      mkdir -p $out/share/java
      cp -n $(< deps) $out/share/java/
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash     = "00n116krll8gpq2p8rkpzqs2qafc71wimwfbmhi4y9c6pjas0baf";
  };
in
stdenv.mkDerivation rec {
  name = "${baseName}-${version}";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jdk deps ];

  phases = [ "installPhase" ];

  extraJavaOpts = "-XX:+UseG1GC -XX:+UseStringDeduplication -Xss4m -Xms100m";

  installPhase = ''
    mkdir -p $out/bin

    makeWrapper ${jre}/bin/java $out/bin/metals-emacs \
      --prefix PATH : ${lib.makeBinPath [ jdk ]} \
      --add-flags "${extraJavaOpts} -Dmetals.client=emacs -cp $CLASSPATH scala.meta.metals.Main"

    makeWrapper ${jre}/bin/java $out/bin/metals-vim \
      --prefix PATH : ${lib.makeBinPath [ jdk ]} \
      --add-flags "${extraJavaOpts} -Dmetals.client=coc.nvim -cp $CLASSPATH scala.meta.metals.Main"

    makeWrapper ${jre}/bin/java $out/bin/metals-sublime \
      --prefix PATH : ${lib.makeBinPath [ jdk ]} \
      --add-flags "${extraJavaOpts} -Dmetals.client=sublime -cp $CLASSPATH scala.meta.metals.Main"
  '';

  meta = with stdenv.lib; {
    homepage = https://scalameta.org/metals/;
    license = licenses.asl20;
    description = "Work-in-progress language server for Scala";
    maintainers = with maintainers; [ tomahna ];
  };
}
