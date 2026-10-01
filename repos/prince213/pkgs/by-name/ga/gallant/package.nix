{
  lib,
  fetchFromGitHub,
  stdenv,

  # nativeBuildInputs
  python3,

  # buildInputs
  libuninameslist,
  libunistring,
}:

stdenv.mkDerivation {
  pname = "gallant";
  version = "0.1-unstable-2026-09-30";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "NanoBillion";
    repo = "gallant";
    rev = "59e9dc64b03c5a2cfa30477447d2f6edb124a6f2";
    hash = "sha256-89VzXkMafND/iA2Tb+gEj+ZkeULS2MSNuJ14cJe49pE=";
  };

  nativeBuildInputs = [
    (python3.withPackages (ps: [
      ps.brotli
      ps.fonttools
    ]))
  ];

  buildInputs = [
    libuninameslist
    libunistring
  ];

  buildFlags = [ "gallant.ttf" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -Dm644 gallant.ttf $out/share/fonts/truetype/gallant.ttf

    runHook postInstall
  '';

  meta = {
    description = "font used by the Sun Microsystems SPARCstation console, extended with glyphs for many Unicode blocks";
    homepage = "https://github.com/NanoBillion/gallant";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ prince213 ];
  };
}
