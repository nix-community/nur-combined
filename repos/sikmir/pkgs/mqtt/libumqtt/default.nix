{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libev,
  lua,
  openssl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libumqtt";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "zhaojh329";
    repo = "libumqtt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rNKcGU0LcTnSaVJjkI3onSpgJUY1apHaoFyx8GmyO8Y=";
    fetchSubmodules = true;
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace src/buffer/buffer.h \
      --replace-fail "<endian.h>" "<machine/endian.h>"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libev
    lua
    openssl
    zlib
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration -Wno-error=misleading-indentation";

  meta = {
    description = "A Lightweight and fully asynchronous MQTT client C library based on libev";
    homepage = "https://github.com/zhaojh329/libumqtt";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
