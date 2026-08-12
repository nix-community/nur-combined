{
  lib,
  stdenvNoCC,
  source,
}:

stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-${source.date}";
  __structuredAttrs = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r "$src/themes" "$out"

    runHook postInstall
  '';

  meta = {
    description = "😽 Soothing pastel theme for Kitty";
    homepage = "https://github.com/catppuccin/kitty";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
