{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chibicc";
  version = "0-unstable-2020-12-07";

  src = fetchFromGitHub {
    owner = "rui314";
    repo = "chibicc";
    rev = "90d1f7f199cc55b13c7fdb5839d1409806633fdb";
    hash = "sha256-sGSPQv9JPXTnyv+7CnmzWq1objCJRctK4wKII8GM26s=";
  };

  installPhase = ''
    install -Dm755 chibicc -t $out/bin
  '';

  meta = {
    description = "A small C compiler";
    homepage = "https://github.com/rui314/chibicc";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
