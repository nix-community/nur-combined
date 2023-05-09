{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxo";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "Juniper";
    repo = "libxo";
    rev = finalAttrs.version;
    hash = "sha256-iTB/zADckrLe6pfNa76CDYf6iozI+WUScd/IQlvFhnE=";
  };

  patches = [
    ./remove-sysctl-include.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with lib; {
    description = "Library for emitting text, XML, JSON, or HTML output";
    homepage = "https://github.com/Juniper/libxo";
    license = licenses.bsd2;
  };
})
