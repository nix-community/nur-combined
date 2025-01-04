{
  source,
  lib,
  stdenv,
  bobcat,
  icmake,
  yodl,
}:

stdenv.mkDerivation {
  inherit (source) pname version src;

  setSourceRoot = ''
    sourceRoot=$(echo */flexc++)
  '';

  buildInputs = [ bobcat ];
  nativeBuildInputs = [
    icmake
    yodl
  ];

  postPatch = ''
    substituteInPlace INSTALL.im --replace /usr $out
    patchShebangs .
  '';

  buildPhase = ''
    ./build man
    ./build manual
    ./build program
  '';

  installPhase = ''
    ./build install x
  '';

  meta = {
    description = "C++ tool for generating lexical scanners";
    mainProgram = "flexc++";
    longDescription = ''
      Flexc++ was designed after `flex'. Flexc++ offers a cleaner class design
      and requires simpler specification files than offered by flex's C++
      option.
    '';
    homepage = "https://fbb-git.gitlab.io/flexcpp/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ definfo ];
  };
}
