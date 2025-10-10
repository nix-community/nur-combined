{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "deeplx";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DeepLX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aJZ6DLq/1XsGevVlKowf1cFhq5cIKLUVNt9XTEx5++Q=";
  };

  vendorHash = "sha256-7RXyLo0eqtTzJPabp0Miwaw6mseGSYhcfRFyWyUCAYE=";

  meta = {
    description = "A powerful free deepL API, no token required";
    homepage = "https://github.com/OwO-Network/DeepLX";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = lib.platforms.linux;
  };
})
