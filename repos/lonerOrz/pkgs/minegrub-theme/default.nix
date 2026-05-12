{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fastfetch,
  python3,

  boot-options-count ? 4,
  splash ? "",
  background ? "",
}:

let
  customAssets = splash != "" || background != "";
in
stdenvNoCC.mkDerivation {
  pname = "minegrub-theme";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "Lxtharia";
    repo = "minegrub-theme";
    rev = "8ba52f8402ed642abf0f6eee32c407412a3ceae6";
    hash = "sha256-wTLOBy3l/FaIGJWRGFTVYsITkou0lmDU3uAMxvOCCN8=";
  };

  buildInputs = lib.optionals customAssets [
    fastfetch
    (python3.withPackages (p: [ p.pillow ]))
  ];

  patchPhase = ''
    sed -i '$d' minegrub/update_theme.py

    top_value=$((170 + (${toString boot-options-count} - 2) * 72))
    sed -i '/^+ image {/,/^}$/s/top = 40%+[0-9]\+/top = 40%+'"$top_value"'/' minegrub/theme.txt
  '';

  buildPhase = lib.optionalString customAssets ''
    bg="${background}"
    if [ -n "$bg" ]; then
      if [ ! -f "$bg" ]; then
        bg="background_options/$bg.png"
        if [ ! -f "$bg" ]; then
          bg=$(find background_options/ -maxdepth 1 -name "*${background}*" -print -quit 2>/dev/null || true)
        fi
        if [ ! -f "$bg" ]; then
          echo "ERROR: background '${background}' not found in background_options/"
          exit 1
        fi
      fi
    fi
    python minegrub/update_theme.py "$bg" "${splash}"
  '';

  installPhase = ''
    mkdir -p $out
    cp minegrub/*.png minegrub/*.pf2 minegrub/theme.txt $out
  '';

  meta = {
    description = "Minecraft-themed GRUB bootloader theme";
    homepage = "https://github.com/Lxtharia/minegrub-theme";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
