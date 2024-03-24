{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation (finalAttrs: {
  pname = "radiolib";
  version = "6.4.2";

  src = fetchFromGitHub {
    owner = "jgromes";
    repo = "RadioLib";
    rev = finalAttrs.version;
    hash = "sha256-9cJZBybenJ160PeDCfWFmsLw4JVJSxNTTWA1Qosy2p0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Universal wireless communication library for embedded devices";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
