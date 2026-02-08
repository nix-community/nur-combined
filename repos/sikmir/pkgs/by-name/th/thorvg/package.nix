{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  libjpeg_turbo,
  libpng,
  libwebp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thorvg";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "thorvg";
    repo = "thorvg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V01jPj52fGtovOHwSXJq/eq4n8TUGVKq7fIzdMmCFk4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libjpeg_turbo
    libpng
    libwebp
  ];

  mesonFlags = [
    (lib.strings.mesonBool "tests" finalAttrs.doCheck)
    (lib.strings.mesonBool "log" true)
    (lib.strings.mesonOption "bindings" "capi")
    (lib.strings.mesonOption "engines" "sw,gl")
    (lib.strings.mesonOption "loaders" "all")
    (lib.strings.mesonOption "savers" "all")
    (lib.strings.mesonOption "tools" "all")
  ];

  doCheck = true;

  meta = {
    description = "A production-ready C++ vector graphics engine supporting SVG and Lottie formats";
    homepage = "https://github.com/thorvg/thorvg";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
