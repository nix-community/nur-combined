{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, sqlite
, zstd
, rustc
}:

rustPlatform.buildRustPackage {
  pname = "moss";
  version = "unstable-2023-10-14";

  src = fetchFromGitHub {
    owner = "serpent-os";
    repo = "moss-rs";
    rev = "034445f065cdd47ee6d8b337e8a6f3d4bcc29bf4";
    hash = "sha256-W4WSl9Xbl0EkoQsgNRCDM3i1bKw71ZRr8pQFTdZbZg0=";
  };

  cargoHash = "sha256-y1v72fTw5hBT8I4xwulwCE0zORBAfcm71gNtyqK/kRI=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    sqlite
    zstd
  ];

  env.ZSTD_SYS_USE_PKG_CONFIG = true;

  meta = {
    description = "The safe, fast and sane package manager for Linux";
    homepage = "https://github.com/serpent-os/moss-rs";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder rustc.version "1.70";
  };
}
