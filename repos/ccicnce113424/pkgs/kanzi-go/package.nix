{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "kanzi-go";
  version = "2.6.0";
  src = fetchFromGitHub {
    owner = "flanglet";
    repo = "kanzi-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Yh0FPzxJt1jEQ7senQ6UVUgPuJUFXG3ZiF+Xh27ymPE=";
  };

  sourceRoot = "${finalAttrs.src.name}/v2";

  vendorHash = null;

  postInstall = "mv $out/bin/app $out/bin/kanzi";

  meta = {
    description = "Fast lossless data compressor";
    homepage = "https://github.com/flanglet/kanzi-go";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "kanzi";
  };
})
