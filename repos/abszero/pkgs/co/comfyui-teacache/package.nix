{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-teacache";
  version = "0-unstable-2025-08-21";

  src = fetchFromGitHub {
    owner = "chenpipi0807";
    repo = "ComfyUI-TeaCache";
    rev = "c981a119454a2bd7fb13d9fbabac6377f3ceb2b0";
    hash = "sha256-ImOSAS8rnCGETJUIHFex1nBstHuDnjr+Z3l1znRXNvU=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    diffusers
    einops
  ];

  installPhase = ''
    runHook preInstall

    INSTALL_DIR="$out/${python3.sitePackages}/custom_nodes"
    mkdir -p $INSTALL_DIR
    cp -r . "$INSTALL_DIR/${final.pname}"

    runHook postInstall
  '';
  
  meta = {
    description = "TeaCache integration for ComfyUI (fork with qwen-image support)";
    homepage = "https://github.com/chenpipi0807/ComfyUI-TeaCache";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ weathercold ];
  };
})
