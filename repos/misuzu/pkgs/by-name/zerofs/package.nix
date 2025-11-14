{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "zerofs";
  version = "0.16.7";

  src = fetchFromGitHub {
    owner = "Barre";
    repo = "ZeroFS";
    tag = "v${version}";
    hash = "sha256-kboNvLn6XQPxiHosqYZKLXib1Yo78d8rzfDLQWKPHQ8=";
  };

  sourceRoot = "${src.name}/zerofs";

  cargoHash = "sha256-Xie718O74HSiXKb838Fj1RikHvF2n9PydHyJAiHkTGw=";

  meta = {
    description = "The Filesystem That Makes S3 your Primary Storage. ZeroFS is 9P/NFS/NBD on top of S3.";
    homepage = "https://github.com/Barre/ZeroFS";
    license = lib.licenses.agpl3Plus;
    mainProgram = "zerofs";
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
