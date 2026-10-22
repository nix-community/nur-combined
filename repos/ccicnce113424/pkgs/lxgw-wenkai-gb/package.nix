{
  lib,
  stdenvNoCC,
  fetchzip,
  installFonts,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lxgw-wenkai-gb";
  version = "1.530";

  src = fetchzip {
    url = "https://github.com/lxgw/LxgwWenkaiGB/releases/download/v${finalAttrs.version}/lxgw-wenkai-gb-v${finalAttrs.version}.tar.gz";
    hash = "sha256-hjt8eJTPSyJDkXIrda3urHIR0N5lgLhrWVsbTP2m2is=";
  };

  nativeBuildInputs = [ installFonts ];

  strictDeps = true;
  __structuredAttrs = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://lxgw.github.io/";
    description = "Open-source Chinese GuoBiao font derived from Fontworks' Klee One";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
  };
})
