{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-prompt-manager";
  version = "3.5.0-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "ComfyAssets";
    repo = "ComfyUI_PromptManager";
    rev = "e71d0ca6b6d029dd1a3347c50162fcb3ff393949";
    hash = "sha256-02NeVZthZ/gd8QjS8/4KNxf8l4r05jv81bzESV4+Nbg=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    fuzzywuzzy
    sqlalchemy
    watchdog
  ];

  # Fix readonly logging dir
  patchPhase = ''
    sed -iE 's|self.log_dir = .*|self.log_dir = Path.home() / ".config/${final.pname}/logs"|
             s|self.log_dir.mkdir(exist_ok=True)|self.log_dir.mkdir(parents=True, exist_ok=True)|' \
             utils/logging_config.py
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    INSTALL_DIR="$out/${python3.sitePackages}/custom_nodes"
    mkdir -p $INSTALL_DIR
    cp -r . "$INSTALL_DIR/${final.pname}"

    runHook postInstall
  '';

  meta = {
    description = "Professional prompt management system for ComfyUI with advanced search, tagging, star ratings, and integrated image galleries. Features modern UI with light/dark modes, bulk operations, and dashboard analytics. Transform your prompt collection into an organized, searchable library";
    homepage = "https://github.com/ComfyAssets/ComfyUI_PromptManager";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ weathercold ];
  };
})
