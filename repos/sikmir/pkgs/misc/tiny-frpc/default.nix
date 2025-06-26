{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "tiny-frpc";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "gofrp";
    repo = "tiny-frpc";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-vrIkSacqjt3lG5LaOXV1m3NI+j0KLFOTV/P5OacwrcU=";
  };

  vendorHash = "sha256-RbqMuLMSIrQQLDXh79hik5+IPqoYa4oXx01ouQYCpgc=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "tiny frpc using ssh protocol with frps";
    homepage = "https://github.com/gofrp/tiny-frpc";
    changelog = "https://github.com/gofrp/tiny-frpc/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "frpc";
  };
})
