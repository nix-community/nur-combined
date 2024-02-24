{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "smallrx";
  version = "0-unstable-2018-12-18";

  src = fetchFromGitHub {
    owner = "ha7ilm";
    repo = "smallrx";
    rev = "e3938a59ffea7aa8e7fa699e471557ed2dfdeed9";
    hash = "sha256-VcTMQAr5617CSPJbktzrKciNiBbveDWjIeE8Gzf9pa8=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "CC=gcc" ""
  '';

  installPhase = "install -Dm755 rx -t $out/bin";

  meta = with lib; {
    description = "amateur radio receiver in <100 code lines";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
