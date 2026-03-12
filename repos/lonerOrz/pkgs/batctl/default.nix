{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "batctl";
  version = "2026.3.13";

  # https://github.com/Ooooze/batctl
  src = fetchFromGitHub {
    owner = "Ooooze";
    repo = "batctl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-beRADDp3jqrM32ghaPz0IZLT9ZnHO1hnbCkeRz1h5bE=";
  };

  vendorHash = "sha256-irJksXupZGHzZ5vbFeI9laKi5+LyATc1lMxpMLLl69w=";

  subPackages = [
    "cmd/batctl"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "TUI and CLI tool for managing battery charge thresholds on Linux laptops";
    homepage = "https://github.com/Ooooze/batctl";
    mainProgram = "batctl";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
