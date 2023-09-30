{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "sqlite-zstd";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "phiresky";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-bl9CF/w6A1Ugz8t+8WimMNOGzysL4eiiu07d2+KND8k=";
  };

  cargoSha256 = "sha256-hjYYcBO3eGuPVFxrP/FMKQAyknNk0Uv5BvOaZ8+1X2M=";

  # TODO use system provided sqlite and zstd
  # buildInputs = [ sqlite zstd ];

  meta = with lib; {
    inherit (src.meta) homepage;
    description =
      "Transparent dictionary-based row-level compression for SQLite";
    license = licenses.lgpl3Plus;
  };
}
