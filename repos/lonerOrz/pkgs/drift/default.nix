{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "drift";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "phlx0";
    repo = "drift";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PEKVwtJGYgyaV31OUMDHbYqS948GqBZ1/gb/n12D3Fo=";
  };

  vendorHash = "sha256-xcSoDytK7cQrECa5PVoLunCG5im2YbOd8/0bclvTaq0=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "A terminal screensaver that turns idle time into ambient art";
    homepage = "https://github.com/phlx0/drift";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "drift";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
