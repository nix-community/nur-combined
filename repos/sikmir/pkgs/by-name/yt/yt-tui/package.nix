{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "yt-tui";
  version = "0.7.8";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nospor";
    repo = "yt-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RMjovk7DrqlW0mxLQCe4AWxhq8gr/vsjE7uAu/M5g3s=";
  };

  vendorHash = "sha256-5/BqDP8b9XNqwbh/0d9Vsyi0lg8JmjcDk6CYkLdAXvM=";

  ldflags = [
    "-s"
    "-w"
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
