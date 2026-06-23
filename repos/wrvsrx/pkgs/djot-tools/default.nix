{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-tools";
    tag = finalAttrs.version;
    hash = "sha256-JZPVdAn5SXH6UlHQFcThehAp70DU3jfpyMBET6s6etA=";
  };

  cargoHash = "sha256-tCrhJSOjTpqzipvWH6k7+yVBRR82xXaeD05XUKvi7vk=";
})
