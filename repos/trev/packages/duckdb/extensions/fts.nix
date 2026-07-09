{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "fts";
  repo = "duckdb-fts";
  branch = "main";
  rev = "69c44bed3ceae0b9dcf2c7888314f37fb3ea8ca3";
  hash = "sha256-s/AEiR7g7vK0sF3dGYzniS3KylxJPk9ar3YeUoHHZlE=";
  loadOptions = [ "DONT_LINK" ];
}
