{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "encodings";
  repo = "duckdb-encodings";
  rev = "2d1447a890302d9dff23ac7c8119ddce53ee65ff";
  hash = "sha256-EF2lbkvQwXjl79VdIlzvsVsxq3VvujGHZO1ELmiA7P4=";
}
