{ lib, stdenv, fetchFromGitHub, cmake, libev, lua, openssl, zlib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "libumqtt";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "zhaojh329";
    repo = "libumqtt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rNKcGU0LcTnSaVJjkI3onSpgJUY1apHaoFyx8GmyO8Y=";
    fetchSubmodules = true;
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace src/buffer/buffer.h \
      --replace-fail "<endian.h>" "<machine/endian.h>"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libev lua openssl zlib ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration -Wno-error=misleading-indentation";

  meta = with lib; {
    description = "A Lightweight and fully asynchronous MQTT client C library based on libev";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
