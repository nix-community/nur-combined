{ stdenv, lib, fetchFromGitHub, cmake, pkgconfig
}:
stdenv.mkDerivation rec {
  pname = "arcwelder";
  version = "1.1.0";

  nativeBuildInputs = [
    cmake
  ];

  patchPhase = ''
    TMP=$(mktemp)
    echo $TMP
    cat CMakeLists.txt | head -n -6 > $TMP
    mv $TMP CMakeLists.txt
    '';

  src = fetchFromGitHub {
    owner = "FormerLurker";
    repo = "ArcWelderLib";
    sha256 = "0lxr0ka105fhbj0l34gi3hdywwih0jpf0vcrlv248r80lwfm735c";
    rev = "${version}";
  };

  meta = with stdenv.lib; {
    description = "G-code postprocessor";
    license = licenses.agpl3;
    maintainers = with maintainers; [ moredread ];
  };
}
