{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "batctl";
  version = "2026.3.11";

  # https://github.com/Ooooze/batctl
  src = fetchFromGitHub {
    owner = "Ooooze";
    repo = "batctl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fHjmodKF3gdSCp3AvsHP0WNxlxSWk3wVi1UqCUyZIs4=";
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
