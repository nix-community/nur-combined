{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "deeplx";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DeepLX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LJC9iSH9XrX87hqhZVLgmSml7wLj6G0H6RE6kxKVyFg=";
  };

  vendorHash = "sha256-HkLlgspXrUHfBGcIsFLDXB4aJzPp6D/MR1/UrY+C7i8=";

  meta = {
    description = "A powerful free deepL API, no token required";
    homepage = "https://github.com/OwO-Network/DeepLX";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = lib.platforms.linux;
  };
})
