{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-autocomplete-plus";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "newtextdoc1111";
    repo = "ComfyUI-Autocomplete-Plus";
    rev = "v${final.version}";
    hash = "sha256-MjhGd38G5Wz46t1AchTe/IqmTzVO43mlXPDHie5i3EE=";
  };

  # Fix readonly config dir
  patchPhase = ''
    sed -iE 's|DATA_DIR = .*|DATA_DIR = os.path.expanduser("~/.config/comfyui-autocomplete-plus")|' \
            modules/api.py \
            modules/downloader.py
  '';

  installPhase = ''
    runHook preInstall

    INSTALL_DIR="$out/${python3.sitePackages}/custom_nodes"
    mkdir -p $INSTALL_DIR
    cp -r . "$INSTALL_DIR/${final.pname}"

    runHook postInstall
  '';

  meta = {
    description = "Autocomplete and Related Tag display for ComfyUI";
    homepage = "https://github.com/newtextdoc1111/ComfyUI-Autocomplete-Plus/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ weathercold ];
  };
})
