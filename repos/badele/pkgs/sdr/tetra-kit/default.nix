{ fetchgit
, cmake
, git
, lib
, stdenv
  # Project Dependencies
, ncurses
, rapidjson
, sox
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tetra-kit";
  version = "2023.05.18";

  src = fetchgit
    {
      url = "https://gitlab.com/larryth/tetra-kit";
      rev = "3a18aec77641a0a408a20d417a34c3e122fa8bbe";
      sha256 = "sha256-mlxSWHEK+b0s1COLdXadwilfZtnlBqx/B4dOiDrwx9c=";
    };

  nativeBuildInputs = [ cmake git rapidjson ];

  doConfigure = false;
  dontUseCmakeConfigure = true;

  buildPhase = ''
    ./build.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp decoder/decoder $out/bin
    cp recorder/recorder $out/bin
    cp codec/{c,s}coder $out/bin
    cp -r phy $out/
  '';

  buildInputs = [
    ncurses
    zlib
    sox
  ];

  meta = with lib; {
    description = "Tetra downlink decoder/recorder kit";
    homepage = "https://gitlab.com/larryth/tetra-kit";
    license = licenses.gpl3;
  };
})
