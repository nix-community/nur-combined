{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tabler-icons";
  version = "3.40.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@tabler/icons-webfont/-/icons-webfont-${finalAttrs.version}.tgz";
    hash = "sha256-arQsZfDE+vsH/TPrvb+yA4CgsK8+sKDIVdssL4QBYC4=";
  };

  sourceRoot = "package";

  installPhase = ''
    runHook preInstall

    fontdir=$out/share/fonts/truetype/tabler-icons
    mkdir -p $fontdir

    for f in dist/fonts/*.ttf; do
      install -Dm644 "$f" "$fontdir/$(basename "$f")"
    done

    runHook postInstall
  '';

  meta = {
    description = "A set of over 5900 free MIT-licensed high-quality icons.";
    homepage = "https://tabler.io/";
    changelog = "https://tabler.io/changelog";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
