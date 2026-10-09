{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "yt-tui";
  version = "0.8.5";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nospor";
    repo = "yt-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l9DMrdX17p5Bksnzy3qUFlxeGZ8rfYqs3xFGWV3lcqE=";
  };

  vendorHash = "sha256-5/BqDP8b9XNqwbh/0d9Vsyi0lg8JmjcDk6CYkLdAXvM=";

  ldflags = [
    "-s"
    "-X main.version=v${finalAttrs.version}"
  ];

  meta = {
    description = "YouTrack Terminal User Interface";
    homepage = "https://github.com/nospor/yt-tui";
    maintainers = with lib.maintainers; [ sikmir ];
    license = lib.licenses.mit;
    mainProgram = "yt-tui";
  };
})
