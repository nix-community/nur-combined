{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "zerofs";
  version = "0.16.2";

  src = fetchFromGitHub {
    owner = "Barre";
    repo = "ZeroFS";
    tag = "v${version}";
    hash = "sha256-NJ/lQ0zE2mPSCfRlbIthhytaGKXQgM2xy3UC5uRfADA=";
  };

  sourceRoot = "${src.name}/zerofs";

  cargoHash = "sha256-Hw6PRgOk2Ub7W0ARnCxNYxGeZ7d4bhMgKPCUn13fvhg=";

  meta = {
    description = "The Filesystem That Makes S3 your Primary Storage. ZeroFS is 9P/NFS/NBD on top of S3.";
    homepage = "https://github.com/Barre/ZeroFS";
    license = lib.licenses.agpl3Plus;
    mainProgram = "zerofs";
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
