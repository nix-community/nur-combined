{ lib, stdenv, fetchFromGitHub, mbedtls }:

stdenv.mkDerivation (finalAttrs: {
  pname = "mongoose";
  version = "7.11";

  src = fetchFromGitHub {
    owner = "cesanta";
    repo = "mongoose";
    rev = finalAttrs.version;
    hash = "sha256-xA/08S1n0ziVUnlN9uuo0fST4DWfLrSB8J6+4tDFCKo=";
  };

  buildInputs = [ mbedtls ];

  buildFlags = [ "linux-libs" ];

  installFlags = [ "PREFIX=$(out)" ];

  preInstall = "mkdir -p $out/lib";

  meta = with lib; {
    description = "Embedded Web Server";
    homepage = "https://mongoose.ws/";
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
