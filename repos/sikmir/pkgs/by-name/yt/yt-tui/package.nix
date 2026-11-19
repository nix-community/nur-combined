{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "yt-tui";
  version = "0.8.6";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nospor";
    repo = "yt-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LSFBbDLi2i+0afL9nkxDyqP29azvoPtPZEF6tOcmT0Q=";
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
