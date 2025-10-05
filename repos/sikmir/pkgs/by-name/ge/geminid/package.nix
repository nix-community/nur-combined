{
  lib,
  stdenv,
  fetchFromGitHub,
  libconfig,
  file,
  openssl,
  flex,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geminid";
  version = "0-unstable-2022-04-15";

  src = fetchFromGitHub {
    owner = "jovoro";
    repo = "geminid";
    rev = "eec25221eadfa47b09de5bd0dc15e90b1263d43a";
    hash = "sha256-d9zs0fqH9YqhNfcPY66Ynoq2xo6n/h+sgRcD80ZBCNU=";
  };

  nativeBuildInputs = [ flex ];

  buildInputs = [
    libconfig
    file
    openssl.dev
  ];

  makeFlags = [
    "geminid"
    "CC:=$(CC)"
    "LEX=flex"
  ];

  installPhase = "install -Dm755 geminid -t $out/bin";

  meta = {
    description = "Gemini Server in C";
    homepage = "https://github.com/jovoro/geminid";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
