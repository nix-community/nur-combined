{ lib, stdenv, fetchFromGitHub, mbedtls }:

stdenv.mkDerivation (finalAttrs: {
  pname = "mongoose";
  version = "7.12";

  src = fetchFromGitHub {
    owner = "cesanta";
    repo = "mongoose";
    rev = finalAttrs.version;
    hash = "sha256-cDaPK9ubXX9x/iJZqEgMxTm/VAFslnA4agtQbhQRc6I=";
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
