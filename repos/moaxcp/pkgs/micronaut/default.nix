{ stdenv, fetchzip, jdk, makeWrapper }:

stdenv.mkDerivation rec {
  name = "micronaut-${version}";
  version = "1.2.1";
  src = fetchzip {
    url = "https://github.com/micronaut-projects/micronaut-core/releases/download/v1.2.1/micronaut-1.2.1.zip";
    sha256 = "0lfl2hfakpdcfii3a3jr6kws731jamy4fb3dmlnj5ydk0zbnmk6r";
  };
  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    rm bin/mn.bat
    cp -r . $out
    wrapProgram $out/bin/mn \
      --prefix JAVA_HOME : ${jdk} 
  '';
}

