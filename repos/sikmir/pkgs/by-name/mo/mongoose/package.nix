{
  lib,
  stdenv,
  fetchFromGitHub,
  mbedtls,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mongoose";
  version = "7.20";

  src = fetchFromGitHub {
    owner = "cesanta";
    repo = "mongoose";
    tag = finalAttrs.version;
    hash = "sha256-qW6HuhcmYwp3e8ioGGP0gSxwxJsqs53KS0jNpMNlWG0=";
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
