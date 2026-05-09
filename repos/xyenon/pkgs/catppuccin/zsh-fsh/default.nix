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
    description = "🐚 Soothing pastel theme for fast-syntax-highlighting";
    homepage = "https://github.com/catppuccin/zsh-fsh";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
