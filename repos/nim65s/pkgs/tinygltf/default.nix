{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "tinygltf";
  version = "2.9.2";

  src = fetchFromGitHub {
    owner = "syoyo";
    repo = "tinygltf";
    rev = "v${version}";
    hash = "sha256-TOwmxNs+5ANUKyepZ4KXix9JMu7U2fBUVfByu2PvRxU=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Header only C++11 tiny glTF 2.0 library";
    homepage = "https://github.com/syoyo/tinygltf";
    license = licenses.mit;
    maintainers = with maintainers; [ nim65s ];
    mainProgram = "tinygltf";
    platforms = platforms.all;
  };
}
