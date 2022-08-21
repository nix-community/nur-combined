{ stdenv
, lib
, fetchFromGitHub
, ant
, jdk8
, jre8
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "beast2";
  version = "2.6.7";

  src = fetchFromGitHub {
    owner = "CompEvol";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-2xIrqCaQD5h/QhUDkRUpf82BRlgaPLdAr23o0lMgBTU=";
  };

  nativeBuildInputs = [ ant jdk8 makeWrapper ];

  propagatedBuildInputs = [ jre8 ];

  patches = ./build.xml.patch;

  buildPhase = ''
    export LANG="en_US.UTF-8"
    export ANT_OPTS="-Dfile.encoding=utf-8"
    export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
    ant linux
  '';

  installPhase = ''
    # Libraries.
    mkdir -p $out
    cp -r release/Linux/beast/lib $out/

    # Binaries.
    mkdir -p $out/bin
    makeWrapper ${jre8}/bin/java $out/bin/applauncher --add-flags "-cp $out/lib/launcher.jar beast.app.tools.AppLauncherLauncher"
    makeWrapper ${jre8}/bin/java $out/bin/beast --add-flags "-cp $out/lib/launcher.jar beast.app.beastapp.BeastLauncher"
    # NOTE: Beauti does not work because it does not find the templates. See the
    # 'release/Linux/beast' directory.
    makeWrapper ${jre8}/bin/java $out/bin/beauti --add-flags "-cp $out/lib/launcher.jar beast.app.beauti.BeautiLauncher -capture"
    makeWrapper ${jre8}/bin/java $out/bin/densitree --add-flags "-cp $out/lib/DensiTree.jar viz.DensiTree"
    makeWrapper ${jre8}/bin/java $out/bin/loganalyser --add-flags "-cp $out/lib/beast.jar beast.util.LogAnalyser"
    makeWrapper ${jre8}/bin/java $out/bin/logcombiner --add-flags "-cp $out/lib/launcher.jar beast.app.tools.LogCombinerLauncher"
    makeWrapper ${jre8}/bin/java $out/bin/packagemanager --add-flags "-cp $out/lib/beast.jar beast.util.PackageManager"
    makeWrapper ${jre8}/bin/java $out/bin/treeannotator --add-flags "-cp $out/lib/launcher.jar beast.app.treeannotator.TreeAnnotatorLauncher"
  '';

  meta = with lib; {
    description = "Bayesian evolutionary analysis by sampling trees";
    license = licenses.lgpl21Only;
    homepage = "https://github.com/CompEvol/beast2";
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.all;
  };
}
