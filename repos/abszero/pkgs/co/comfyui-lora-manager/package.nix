{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-lora-manager";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "willmiao";
    repo = "ComfyUI-Lora-Manager";
    tag = "v${final.version}";
    hash = "sha256-HFjrFtgwc+2CUWj6j1yAYldfYmoaFyI9EqpteMZJkrg=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    aiosqlite
    beautifulsoup4
    gitpython
    jinja2
    natsort
    numpy
    olefile
    piexif
    pillow
    platformdirs
    pyyaml
    safetensors
    toml
  ];

  installPhase = ''
    runHook preInstall

    INSTALL_DIR="$out/${python3.sitePackages}/custom_nodes"
    mkdir -p $INSTALL_DIR
    cp -r . "$INSTALL_DIR/${final.pname}"

    runHook postInstall
  '';

  meta = {
    description = "LoRA Manager for ComfyUI";
    longDescription = ''
      A powerful extension for organizing, previewing, and integrating LoRA
      models with metadata and workflow support.
      Warning: server features not working.
    '';
    homepage = "https://github.com/willmiao/ComfyUI-Lora-Manager";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ weathercold ];
  };
})
