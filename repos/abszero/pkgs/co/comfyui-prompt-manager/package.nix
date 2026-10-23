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
    rev = "b4c7a15045096920d5f2355618e505db9050b632";
    hash = "sha256-iAkHZ17NMb+2WphU7gM07t5vZW3zqIbA7Gsa3q4xqrg=";
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
