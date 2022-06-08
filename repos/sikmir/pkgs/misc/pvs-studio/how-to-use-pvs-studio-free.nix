{ lib, stdenv, fetchFromGitHub, fetchpatch, cmake }:

stdenv.mkDerivation rec {
  pname = "how-to-use-pvs-studio-free";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "viva64";
    repo = pname;
    rev = version;
    hash = "sha256-aFqk0WsMylRQqvlb+M5IfDHVwMBuKNQpCiiGPrj+jEw=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/viva64/how-to-use-pvs-studio-free/commit/5685a069d9538242a79d099fed3057de37a8d766.patch";
      sha256 = "sha256-xffOthjpBVP1aijdO6LTnHNQ3pvrO0/W3YJWIWLMuuQ=";
    })
  ];

  nativeBuildInputs = [ cmake ];

  postPatch = lib.optionalString (!stdenv.isDarwin) ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX \"/usr\")" ""
  '';

  meta = with lib; {
    description = "How to use PVS-Studio for Free?";
    homepage = "https://pvs-studio.com/en/blog/posts/0457/";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
