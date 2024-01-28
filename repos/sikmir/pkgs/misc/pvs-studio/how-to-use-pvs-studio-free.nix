{ lib, stdenv, fetchFromGitHub, fetchpatch, cmake }:

stdenv.mkDerivation (finalAttrs: {
  pname = "how-to-use-pvs-studio-free";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "viva64";
    repo = "how-to-use-pvs-studio-free";
    rev = finalAttrs.version;
    hash = "sha256-aFqk0WsMylRQqvlb+M5IfDHVwMBuKNQpCiiGPrj+jEw=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/viva64/how-to-use-pvs-studio-free/commit/5685a069d9538242a79d099fed3057de37a8d766.patch";
      hash = "sha256-xffOthjpBVP1aijdO6LTnHNQ3pvrO0/W3YJWIWLMuuQ=";
    })
  ];

  postPatch = ''
    sed -i '10i #include <cstdint>' comments.h
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX \"/usr\")" ""
  '';

  nativeBuildInputs = [ cmake ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=unqualified-std-cast-call";

  meta = with lib; {
    description = "How to use PVS-Studio for Free?";
    homepage = "https://pvs-studio.com/en/blog/posts/0457/";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
