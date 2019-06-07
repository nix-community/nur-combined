{ stdenv, jdk, jre, coursier, makeWrapper }:

{ baseName, packageName, version, executable, flags ? {}, meta ? {}}:

let
  scalaVersion = "2.12";
in
stdenv.mkDerivation rec {
  name = "${baseName}-${version}";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jdk ];

  doCheck = true;
  
  phases = [ "buildPhase" "installPhase" "checkPhase" ];

  buildCommand = ''
      mkdir -p $out/share/java
      mkdir -p $out/bin
      export COURSIER_CACHE=$(pwd)
      ${coursier}/bin/coursier bootstrap ${flags} ${packageName}:${baseName}_${scalaVersion}:${version} -o $out/bin/${executable} 
      chmod +x $out/bin/${executable}
  '';
  installPhase = ''
    wrapProgram $out/bin/${executable} --set JAVA_HOME=${jre} --add-flags "-cp $CLASSPATH"
  '';

  checkPhase = ''
    $out/bin/${executable} --version | grep -q "${version}"
  '';

  inherit meta;
}
