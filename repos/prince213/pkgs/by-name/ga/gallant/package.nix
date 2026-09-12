{
  lib,
  fetchFromGitHub,
  stdenv,

  # nativeBuildInputs
  python3,
}:

stdenv.mkDerivation {
  pname = "gallant";
  version = "0.1-unstable-2026-09-11";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "NanoBillion";
    repo = "gallant";
    rev = "c216623d67c4153765b39fcdc2ba61d66e335e64";
    hash = "sha256-fqcQydF8lD7PDb6VD+36QiST4/1YNjKsJPjB/QJlqOc=";
  };

  patches = [
    ./GNUmakefile.patch
  ];

  nativeBuildInputs = [
    (python3.withPackages (ps: [
      ps.brotli
      ps.fonttools
    ]))
  ];

  preBuild = ''
    mkdir -p svg
  '';

  buildFlags = [ "gallant.ttf" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -Dm 644 gallant.ttf $out/share/fonts/truetype/gallant.ttf

    runHook postInstall
  '';

  meta = {
    description = "font used by the Sun Microsystems SPARCstation console, extended with glyphs for many Unicode blocks";
    homepage = "https://github.com/NanoBillion/gallant";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ prince213 ];
  };
}
