{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "how-to-use-pvs-studio-free";
  version = "2021-02-08";

  src = fetchFromGitHub {
    owner = "viva64";
    repo = pname;
    rev = "abc39706151159d102d29e3e2f2b8d5688362ec3";
    hash = "sha256-MDJ2z4gmnLxnO9YNlYbfwMDAwLTnc634w6I1wf0OvYM=";
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
