{
  lib,
  stdenvNoCC,
  fetchzip,
  installFonts,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zhuque";
  version = "0.212";

  src = fetchzip {
    url = "https://github.com/TrionesType/zhuque/releases/download/v${finalAttrs.version}/ZhuqueFangsong-v${finalAttrs.version}.zip";
    hash = "sha256-see78H4ClZON4pujyUxvCjphFrKG73qBVEyhRoSxZ0Y=";
  };

  nativeBuildInputs = [ installFonts ];

  strictDeps = true;
  __structuredAttrs = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/TrionesType/zhuque";
    description = "Open-source Chinese Fangsong font";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
  };
})
