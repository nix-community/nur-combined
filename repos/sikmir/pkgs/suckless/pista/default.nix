{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pista";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "xandkar";
    repo = "pista";
    tag = finalAttrs.version;
    hash = "sha256-lre6SIVyxCwEohLlvSfYs+JnHS1VXTbl3FlUNZ3TGy4=";
  };

  buildInputs = [ libX11 ];

  installPhase = ''
    install -Dm755 pista -t $out/bin
  '';

  meta = {
    description = "Piped status: the ii of status bars!";
    homepage = "https://github.com/xandkar/pista";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
