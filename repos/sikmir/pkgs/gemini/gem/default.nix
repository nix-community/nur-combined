{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gem";
  version = "0-unstable-2024-08-29";

  src = fetchFromGitHub {
    owner = "wrclark";
    repo = "gem";
    rev = "50c24989ce407bba55d4d7fd3b1cd6f165594463";
    hash = "sha256-AsLUAHnNSjKKzKL6Am/DfV4GTdIozdF6k+hmAdHr4jc=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace "CFLAGS +=" "#CFLAGS +="
  '';

  buildInputs = [ openssl ];

  makeFlags = [ "CC:=$(CC)" ];

  installPhase = ''
    install -Dm755 gem -t $out/bin
  '';

  meta = {
    description = "gemini server";
    homepage = "https://github.com/wrclark/gem";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
