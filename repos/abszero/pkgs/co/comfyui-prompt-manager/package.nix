{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-prompt-manager";
  version = "3.3.1-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "ComfyAssets";
    repo = "ComfyUI_PromptManager";
    rev = "5123654b0defe75cea187cabf14dc5ec3017300f";
    hash = "sha256-3P7m6tWMc75tx8OHJAKiOh4qCgVZWIFcGsStf0vHdx8=";
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
