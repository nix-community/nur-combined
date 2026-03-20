{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "pug";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "leg100";
    repo = "pug";
    tag = "v${finalAttrs.version}";
    hash = "sha256-evt2wlRFjCcO+2IWme55QCEPuI0jluVaS/fGQVWEd44=";
  };

  vendorHash = "sha256-jKQ979iDsTMjiH7F5k4EKUzTxyQgZNIs0xhi4ZqZD2E=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/leg100/pug/internal/version.Version=${finalAttrs.version}"
  ];

  doCheck = false;

  meta = {
    description = "Drive terraform at terminal velocity";
    homepage = "https://github.com/leg100/pug";
    changelog = "https://github.com/leg100/pug/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pug";
  };
})
