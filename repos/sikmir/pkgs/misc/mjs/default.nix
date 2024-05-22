{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mjs";
  version = "2.20.0";

  src = fetchFromGitHub {
    owner = "cesanta";
    repo = "mjs";
    rev = finalAttrs.version;
    hash = "sha256-FBMoP28942Bwx0zFISBPYvH6jvXqLFmvDXHkxLHBCjY=";
  };

  postPatch = ''
    patchShebangs tools
    substituteInPlace Makefile \
      --replace-warn "MAKEFLAGS" "#MAKEFLAGS" \
      --replace-warn " clang " " \$(CC) "
  '';

  nativeBuildInputs = [ python3 ];

  makeFlags = [
    "DOCKER_GCC="
    "DOCKER_CLANG="
  ];

  installPhase = ''
    install -Dm755 build/mjs -t $out/bin
  '';

  meta = with lib; {
    description = "Embedded JavaScript engine for C/C++";
    homepage = "https://mongoose.ws/";
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    mainProgram = "mjs";
  };
})
