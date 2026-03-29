{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "drift";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "phlx0";
    repo = "drift";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sB4yOgiK9e73OFLdD6mkF7AQUlzyUltJBJUPDVXLa0U=";
  };

  vendorHash = "sha256-FsNa9qp2MnPk1onv/O13mFi+82yP7D4LdILZsNzHs+4=";

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
