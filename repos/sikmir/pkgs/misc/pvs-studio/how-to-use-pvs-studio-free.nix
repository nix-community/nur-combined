{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "how-to-use-pvs-studio-free";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "viva64";
    repo = pname;
    rev = version;
    hash = "sha256-aFqk0WsMylRQqvlb+M5IfDHVwMBuKNQpCiiGPrj+jEw=";
  };

  nativeBuildInputs = [ cmake ];

  postPatch = lib.optionalString (!stdenv.isDarwin) ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX \"/usr\")" ""
  '' + lib.optionalString stdenv.cc.isClang ''
    substituteInPlace CMakeLists.txt \
      --replace "stdc++fs" "c++fs"
  '';

  meta = with lib; {
    description = "How to use PVS-Studio for Free?";
    homepage = "https://pvs-studio.com/en/blog/posts/0457/";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
