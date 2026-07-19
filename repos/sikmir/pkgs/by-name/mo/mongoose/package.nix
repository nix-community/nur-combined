{
  lib,
  stdenv,
  fetchFromGitHub,
  mbedtls,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mongoose";
  version = "7.22";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "cesanta";
    repo = "mongoose";
    tag = finalAttrs.version;
    hash = "sha256-7XBEzIKXnLlITvtIdu3ldB/ISqGT+8o4pd5qcxJHnKE=";
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
