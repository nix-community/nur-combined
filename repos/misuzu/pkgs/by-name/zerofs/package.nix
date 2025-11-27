{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "zerofs";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "Barre";
    repo = "ZeroFS";
    tag = "v${version}";
    hash = "sha256-G+kXAlPfo3YhAGy9nkKCL7384dWUvPr4cZ+WIX99OSc=";
  };

  sourceRoot = "${src.name}/zerofs";

  cargoHash = "sha256-XbjtlWQkXanOo7SbbgsZNXj5SKy0PQAd2eRM/9f9gLs=";

  meta = {
    description = "The Filesystem That Makes S3 your Primary Storage. ZeroFS is 9P/NFS/NBD on top of S3.";
    homepage = "https://github.com/Barre/ZeroFS";
    license = lib.licenses.agpl3Plus;
    mainProgram = "zerofs";
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
