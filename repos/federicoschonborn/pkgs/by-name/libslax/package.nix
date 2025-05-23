{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  curl,
  libxml2,
  libxslt,
}:

let
  libxslt' = libxslt.overrideAttrs (prevAttrs: {
    configureFlags = (prevAttrs.configureFlags or [ ]) ++ [
      (lib.withFeature true "debugger")
    ];
  });
in

stdenv.mkDerivation (finalAttrs: {
  pname = "libslax";
  version = "3.1.3";

  src = fetchFromGitHub {
    owner = "Juniper";
    repo = "libslax";
    tag = finalAttrs.version;
    hash = "sha256-nVshpBEJ9HcATLqV4hWAVRyxAbNQFKaXoN+xTHmQ4MU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    bison
    curl # curl-config
    libxml2 # xml2-config
    libxslt' # xslt-config
  ];

  buildInputs = [
    curl
    libxml2
    libxslt'
  ];

  strictDeps = true;

  env.NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration";

  meta = {
    mainProgram = "libslax";
    description = "C implementation of the SLAX programming language";
    homepage = "https://github.com/Juniper/libslax";
    changelog = "https://github.com/Juniper/libslax/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
