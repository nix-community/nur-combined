{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  plutovg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lunasvg";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CBhz117Y8e7AdD1JJtNkR/EthsfyiQ05HW41beaY95I=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "plutovg 0.0.4" "plutovg"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ plutovg ];

  meta = {
    description = "SVG rendering and manipulation library in C++";
    homepage = "https://github.com/sammycage/lunasvg";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
