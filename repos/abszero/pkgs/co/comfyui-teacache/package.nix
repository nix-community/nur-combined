{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-teacache";
  version = "0-unstable-2026-03-08";

  src = fetchFromGitHub {
    owner = "choovin";
    repo = "ComfyUI-TeaCache";
    rev = "b437dd97b656e5f091b16e4d6a84194d2f5d6734";
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
    description = "TeaCache integration for ComfyUI (fork with fixes for latest version)";
    homepage = "https://github.com/choovin/ComfyUI-TeaCache";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ weathercold ];
  };
})
