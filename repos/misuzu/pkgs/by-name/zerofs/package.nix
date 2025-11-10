{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "zerofs";
  version = "0.16.5";

  src = fetchFromGitHub {
    owner = "Barre";
    repo = "ZeroFS";
    tag = "v${version}";
    hash = "sha256-yIy+tqUKSZY9CIQYDUNnFGrWDzxd5LUMCFzzm6SFTRA=";
  };

  sourceRoot = "${src.name}/zerofs";

  cargoHash = "sha256-wwXdkmwKo/PatE21zEHKBgvDf2n1haiBpDj0BDmz3wM=";

  meta = {
    description = "The Filesystem That Makes S3 your Primary Storage. ZeroFS is 9P/NFS/NBD on top of S3.";
    homepage = "https://github.com/Barre/ZeroFS";
    license = lib.licenses.agpl3Plus;
    mainProgram = "zerofs";
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
