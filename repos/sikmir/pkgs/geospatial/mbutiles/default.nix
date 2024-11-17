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

  cargoHash = "sha256-Qf0qWolEGSnptiqGmgZZiXmY+XCvvmk0lJjnosy+8nI=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ sqlite ];

  meta = {
    description = "mbtiles utility in Rust, generate MBTiles from tiles directories and extract tiles from MBTiles file";
    homepage = "https://github.com/amarant/mbutiles";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # error on crate `time` caused by an API change in Rust 1.80.0
  };
}
