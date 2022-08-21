{ stdenv
, lib
, fetchFromGitHub
, ant
, jdk8
, jre8
, makeWrapper
}:

stdenv.mkDerivation {
  pname = "beast";
  version = "sars-cov-2-origins";

  src = fetchFromGitHub {
    owner = "beast-dev";
    repo = "beast-mcmc";
    rev = "sars-cov-2-origins";
    hash = "sha256-RvJy3TZPdXV+c8L5rULnWnbaAjBTQKoWLcOFU8drSis=";
  };

  nativeBuildInputs = [ ant jdk8 makeWrapper ];

  propagatedBuildInputs = [ jre8 ];

  buildPhase = ''
    export LANG="en_US.UTF-8"
    export ANT_OPTS="-Dfile.encoding=utf-8"
    export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
    ant linux
  '';

  installPhase = ''
    # Libraries.
    mkdir -p $out/lib
    cp build/dist/beast.jar $out/lib/
    cp build/dist/beauti.jar $out/lib/

    # Binaries.
    mkdir -p $out/bin
    makeWrapper ${jre8}/bin/java $out/bin/beast --add-flags "-cp $out/lib/beast.jar dr.app.beast.BeastMain"
    makeWrapper ${jre8}/bin/java $out/bin/beauti --add-flags "-jar $out/lib/beauti.jar"
    makeWrapper ${jre8}/bin/java $out/bin/loganalyser --add-flags "-cp $out/lib/beast.jar dr.app.tools.LogAnalyser"
    makeWrapper ${jre8}/bin/java $out/bin/logcombiner --add-flags "-cp $out/lib/beast.jar dr.app.tools.LogCombiner"
    makeWrapper ${jre8}/bin/java $out/bin/treeannotator --add-flags "-cp $out/lib/beast.jar dr.app.tools.TreeAnnotator"
    makeWrapper ${jre8}/bin/java $out/bin/treestat --add-flags "-cp $out/lib/beast.jar dr.app.treestat.TreeStatApp"
  '';

  meta = with lib; {
    description = "Program for Bayesian analysis of molecular sequences using MCMC";
    license = licenses.lgpl21Only;
    homepage = "https://github.com/beast-dev/beast-mcmc";
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.all;
  };
}
