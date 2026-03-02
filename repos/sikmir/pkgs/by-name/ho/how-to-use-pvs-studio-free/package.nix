{
  lib,
  stdenv,
  fetchfromgh,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "how-to-use-pvs-studio-free";
  version = "7.41";

  src = fetchfromgh {
    owner = "viva64";
    repo = "how-to-use-pvs-studio-free";
    tag = finalAttrs.version;
    hash = "sha256-t7gqTEMPCAC0gXYI+TMcV2XJFSZ6+eclzoF+eCWKP/c=";
    name = "how-to-use-pvs-studio-free_Source_code.tar.gz";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "set(CMAKE_INSTALL_PREFIX \"/usr\")" ""
  '';

  nativeBuildInputs = [ cmake ];

  setupHook = ./setup-hook.sh;

  meta = {
    description = "How to use PVS-Studio for Free?";
    homepage = "https://pvs-studio.com/en/blog/posts/0457/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
