{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kilo";
  version = "0-unstable-2025-01-04";

  src = fetchFromGitHub {
    owner = "antirez";
    repo = "kilo";
    rev = "323d93b29bd89a2cb446de90c4ed4fea1764176e";
    hash = "sha256-f4DlVCX9i58YUqhyuEd6WwdHD15jQokl+mKA0tjYplM=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 kilo -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "A text editor in less than 1000 LOC with syntax highlight and search";
    homepage = "https://github.com/antirez/kilo";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
