{ lib, stdenv
, fetchFromGitHub
, cmake
#, pkg-config
, python3
, swig2 # 2.0
#, autoreconfHook
}:

stdenv.mkDerivation rec {
  pname = "pocketsphinx";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "cmusphinx";
    repo = "pocketsphinx";
    rev = "v${version}";
    hash = "sha256-Oa2vVVpsB3Jj5KvLcKfMP5Vu9xSeO7g1qNC5cQE3F7Y=";
  };

/*
  configurePhase = ''
    echo CMAKE_MODULE_PATH=$CMAKE_MODULE_PATH
    exit 1
  '';
*/

  nativeBuildInputs = [
    cmake
    #pkg-config
    #autoreconfHook
  ];
  buildInputs = [
    python3
    swig2
  ];

  meta = {
    description = "Speech recognition engine";
    homepage = "https://github.com/cmusphinx/pocketsphinx";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
  };
}
