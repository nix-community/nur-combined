{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  sageattention ? sageattention_1,
  sageattention_1 ? null,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "comfyui-anima-booster";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "BlackSnowSkill";
    repo = "ANIMA_BOOSTER";
    tag = "v${final.version}";
    hash = "sha256-E2zGQh5iIGeae9rkzUvu7HiX3n+DqPk9XW2L2TDY5po=";
  };

  propagatedBuildInputs = lib.optional (sageattention != null) sageattention;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    INSTALL_DIR="$out/${python3.sitePackages}/custom_nodes"
    mkdir -p $INSTALL_DIR
    cp -r . "$INSTALL_DIR/${final.pname}"

    runHook postInstall
  '';

  meta = {
    description = "High-performance optimization suite for Anima DiT 2B model in ComfyUI";
    homepage = "https://github.com/BlackSnowSkill/ANIMA_BOOSTER";
    changelog = "https://github.com/BlackSnowSkill/ANIMA_BOOSTER/releases/tag/v${final.version}";
    license = lib.licenses.unfree; # All rights reserved
    maintainers = with lib.maintainers; [ weathercold ];
  };
})
