{
  lib,
  stdenv,
  fetchFromGitHub,
  mbedtls,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mongoose";
  version = "7.13";

  src = fetchFromGitHub {
    owner = "cesanta";
    repo = "mongoose";
    tag = finalAttrs.version;
    hash = "sha256-9XHUE8SVOG/X7SIB52C8EImPx4XZ7B/5Ojwmb0PkiuI=";
  };

  buildInputs = [ mbedtls ];

  buildFlags = [ "linux-libs" ];

  installFlags = [ "PREFIX=$(out)" ];

  preInstall = "mkdir -p $out/lib";

  meta = {
    description = "Embedded Web Server";
    homepage = "https://mongoose.ws/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
