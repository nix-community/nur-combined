{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "drift";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "phlx0";
    repo = "drift";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Gom5PQovsC9Q0jQN2kdJzo2D/uqKGA0i8wJ2Kc/XbfQ=";
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
