{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-prompt-manager";
  version = "1.0.0-unstable-2026-10-09";

  src = fetchFromGitHub {
    owner = "ComfyAssets";
    repo = "ComfyUI_PromptManager";
    rev = "da322f8c947016f682c8ecf9e1c0719841e6ed75";
    hash = "sha256-w/73pCvsGeZeqTUDEzDbq1kD4U2FhMbvI9gC6EzKOeU=";
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
