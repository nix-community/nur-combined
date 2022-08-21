{ ant
, fetchFromGitHub
, fetchurl
, jdk
, jre
, lib
, makeWrapper
, stdenv
}:

let
  or-tools-jar = fetchurl {
    url = "https://repo1.maven.org/maven2/com/google/ortools/ortools-java/9.0.9048/ortools-java-9.0.9048.jar";
    hash = "sha256-x8zqeMVjaMGx++sK6641JfzbM9s0D982vi4SCNWKE8o=";
  };
in
stdenv.mkDerivation rec {
  version = "1.4.1";
  pname = "jugglinglab";

  src = fetchFromGitHub {
    owner = "jkboyce";
    repo = "jugglinglab";
    rev = "v${version}";
    hash = "sha256-GQm/TMQ1WSEn/6xOSqO0X3D8e/KpkQVz9Imtn6NDbOI=";
  };

  nativeBuildInputs = [ ant jdk makeWrapper ];
  buildInputs = [ jre ];

  configurePhase = ''
    mkdir -p bin/ortools-lib
    ln -s ${or-tools-jar} bin/ortools-lib/com.google.ortools.jar
  '';

  buildPhase = ''
    ant
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/lib"
    cp bin/JugglingLab.jar $out/lib/

    makeWrapper ${jre}/bin/java $out/bin/jugglinglab \
      --add-flags "-jar $out/lib/JugglingLab.jar"
  '';

  meta = with lib; {
    description = "A program to visualize different juggling pattens";
    license = licenses.gpl2;
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.all;
  };
}
