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
    rev = "997985fccb433682f008bb710d9fffb8c4b893cf";
    hash = "";
  };

  cargoHash = "";

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
    broken = versionOlder version "23.11";
  };
}
