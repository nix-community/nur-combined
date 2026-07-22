{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-manager";
  version = "4.2.2-unstable-2026-07-22";

  src = fetchFromGitHub {
    owner = "Comfy-Org";
    repo = "ComfyUI-Manager";
    rev = "579bf48edf8bbfd3a5d14e621b8e3eb0b1d033d9";
    hash = "sha256-5pC7sWQ1G/qAmEhh4NrBwlAXmp9BAnx6Mi/yCsEooCs=";
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
