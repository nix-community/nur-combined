{ lib, mkDerivation, cmake, boost, qtbase, qtwebkit
, gtest, minizip, libsndfile, libvorbis, lsd2dsl }:

mkDerivation rec {
  pname = "lsd2dsl";
  version = lib.substring 0 7 src.rev;
  src = lsd2dsl;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost qtbase qtwebkit minizip libsndfile libvorbis ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "-Werror " "" \
      --replace "add_subdirectory(tests)" ""
  '';

  cmakeFlags = [ "-DCMAKE_PREFIX_PATH=${qtwebkit.dev}" ];

  #doCheck = true;
  #checkInputs = [ gtest ];
  #checkPhase = "(cd tests && ./tests)";

  installPhase = ''
    install -Dm755 console/lsd2dsl $out/bin/lsd2dsl
    install -m755 gui/lsd2dsl-qtgui $out/bin/lsd2dsl-qtgui
  '';

  meta = with lib; {
    description = lsd2dsl.description;
    homepage = lsd2dsl.homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
