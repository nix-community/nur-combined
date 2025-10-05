{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ghc_filesystem,
  glfw,
  libglvnd,
  libGLU,
}:

stdenv.mkDerivation {
  pname = "objlab";
  version = "0-unstable-2019-11-23";

  src = fetchFromGitHub {
    owner = "lighttransport";
    repo = "objlab";
    rev = "c9d50b466f477722578ddf14565561d778c1b4b9";
    hash = "sha256-mE4s+viW6fGfnd8+LlDH4LyRLQ91nwe9dtxyI+dIhsM=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "add_subdirectory" "#add_subdirectory"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    ghc_filesystem
    glfw
    libglvnd
    libGLU
  ];

  env.NIX_CFLAGS_COMPILE = "-fpermissive";

  cmakeFlags = [ (lib.cmakeFeature "OpenGL_GL_PREFERENCE" "GLVND") ];

  installPhase = ''
    install -Dm755 objlab -t $out/bin
  '';

  meta = {
    description = "Simple wavefront .obj viewer";
    homepage = "https://github.com/lighttransport/objlab";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "objlab";
  };
}
