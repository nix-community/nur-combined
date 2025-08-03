{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  sqlite,
}:

rustPlatform.buildRustPackage {
  pname = "mbutiles";
  version = "0.1.0-unstable-2024-04-12";

  src = fetchFromGitHub {
    owner = "amarant";
    repo = "mbutiles";
    rev = "1f59d2d5c8e9f97c632f791c92200759012a490b";
    hash = "sha256-w+fAfRHi/+TaQ4n9AjfBIbXeemCOnkFxR08ev1f+oTc=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-5lHKJ0kb/Zn3hSY6ZFARz60GPWKQ56fsbqL9Lq9VOqE=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ sqlite ];

  meta = {
    description = "mbtiles utility in Rust, generate MBTiles from tiles directories and extract tiles from MBTiles file";
    homepage = "https://github.com/amarant/mbutiles";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
