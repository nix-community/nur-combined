{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, sqlite
, zstd
}:

rustPlatform.buildRustPackage {
  pname = "moss-rs";
  version = "unstable-2023-09-25";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "8a0de12f9d4b094b75280e79b39b1a3feca679ef";
    hash = "sha256-yb36WkGyl2bXTAZKx1oWxAUBVD5BdVLWnMN7rXfza7g=";
  };

  cargoHash = "sha256-DGQGiERR5SNVZcoKRdbqI5DVNjMyQW9kn+AvwM4e0UQ=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    sqlite
    zstd
  ];

  env.ZSTD_SYS_USE_PKG_CONFIG = true;

  meta = with lib; {
    description = "The safe, fast and sane package manager for Linux";
    homepage = "https://github.com/serpent-os/moss-rs";
    mainProgram = "moss";
    platforms = platforms.linux;
    license = licenses.mpl20;
    maintainers = with maintainers; [ federicoschonborn ];
    broken = versionOlder version "23.05";
  };
}
