{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "zerofs";
  version = "0.16.6";

  src = fetchFromGitHub {
    owner = "Barre";
    repo = "ZeroFS";
    tag = "v${version}";
    hash = "sha256-Lh12G3kqb8H9h+KIoJKEB16CLPh0ZaT2yNm7PGj5lhQ=";
  };

  sourceRoot = "${src.name}/zerofs";

  cargoHash = "sha256-lJM/zfvKjz67/ib7kPOWm7ODUAtrLB32oj5L4HwK0WE=";

  meta = {
    description = "The Filesystem That Makes S3 your Primary Storage. ZeroFS is 9P/NFS/NBD on top of S3.";
    homepage = "https://github.com/Barre/ZeroFS";
    license = lib.licenses.agpl3Plus;
    mainProgram = "zerofs";
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
