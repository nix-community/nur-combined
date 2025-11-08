{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "zerofs";
  version = "0.16.4";

  src = fetchFromGitHub {
    owner = "Barre";
    repo = "ZeroFS";
    tag = "v${version}";
    hash = "sha256-eV35c8T3QI92PwC1rx/KHfZsqTc81vfiqOHnLcNmvDk=";
  };

  sourceRoot = "${src.name}/zerofs";

  cargoHash = "sha256-DLZcQDNESFeZDWJclO3nvyf9+Z0q2aJTHGblbggiscU=";

  meta = {
    description = "The Filesystem That Makes S3 your Primary Storage. ZeroFS is 9P/NFS/NBD on top of S3.";
    homepage = "https://github.com/Barre/ZeroFS";
    license = lib.licenses.agpl3Plus;
    mainProgram = "zerofs";
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
