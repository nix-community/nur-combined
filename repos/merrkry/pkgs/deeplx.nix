{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "deeplx";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DeepLX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M51z7iXJmYSRc9bsVPsbhD3v8Fq8Gwg+CO37B18wRZo=";
  };

  vendorHash = "sha256-sukJQkCgGZcqGp1VQam8LHdLroSU7wm0WNIC2eX8OQA=";

  meta = {
    description = "A powerful free deepL API, no token required";
    homepage = "https://github.com/OwO-Network/DeepLX";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = lib.platforms.linux;
  };
})
