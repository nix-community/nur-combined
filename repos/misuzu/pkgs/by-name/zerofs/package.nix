{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "zerofs";
  version = "0.17.3";

  src = fetchFromGitHub {
    owner = "Barre";
    repo = "ZeroFS";
    tag = "v${version}";
    hash = "sha256-6Z5NVjy0vAtZ/TIdw0drV68XDlVHl8cQWfGC+y4rhOM=";
  };

  sourceRoot = "${src.name}/zerofs";

  cargoHash = "sha256-JBE4b6xzTnpw/r+Djm6s6uYRkztOpJdIDhbwI+Fh/Co=";

  meta = {
    description = "The Filesystem That Makes S3 your Primary Storage. ZeroFS is 9P/NFS/NBD on top of S3.";
    homepage = "https://github.com/Barre/ZeroFS";
    license = lib.licenses.agpl3Plus;
    mainProgram = "zerofs";
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
