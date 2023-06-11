{ lib, stdenv, fetchFromGitHub, mbedtls }:

stdenv.mkDerivation (finalAttrs: {
  pname = "mongoose";
  version = "7.10";

  src = fetchFromGitHub {
    owner = "cesanta";
    repo = "mongoose";
    rev = finalAttrs.version;
    hash = "sha256-e2Kj1FCns+v1JIYp5CV8OfxYOaEM8kG86V/PAN2Gui0=";
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
