{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-manager";
  version = "4.2.2-unstable-2026-08-15";

  src = fetchFromGitHub {
    owner = "Comfy-Org";
    repo = "ComfyUI-Manager";
    rev = "1b765ac340c021fbecf0a0cdd1a8a1188637fe7e";
    hash = "sha256-Tr4Kja+GaTOnshx/ZQ1Krak4XSHEMMHR11WjZIAFYzc=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    chardet
    gitpython
    huggingface-hub
    matrix-nio
    pygithub
    rich
    toml
    transformers
    typer
    typing-extensions
    uv
  ];

  installPhase = ''
    runHook preInstall

    INSTALL_DIR="$out/${python3.sitePackages}/custom_nodes"
    mkdir -p $INSTALL_DIR
    cp -r . "$INSTALL_DIR/${final.pname}"

    runHook postInstall
  '';

  meta = {
    description = "Extension designed to enhance the usability of ComfyUI";
    longDescription = ''
      ComfyUI-Manager is an extension designed to enhance the usability of
      ComfyUI. It offers management functions to install, remove, disable, and
      enable various custom nodes of ComfyUI. Furthermore, this extension
      provides a hub feature and convenience functions to access a wide range
      of information within ComfyUI.
      Warning: cannot install pip packages.
    '';
    homepage = "https://github.com/Comfy-Org/ComfyUI-Manager";
    changelog = "https://github.com/Comfy-Org/ComfyUI-Manager/blob/${final.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ weathercold ];
  };
})
