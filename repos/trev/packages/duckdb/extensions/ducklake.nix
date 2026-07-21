{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "d8a1881e22516ea3d186d73e83c65fe5bd1a1dc4";
  hash = "sha256-ULIM7qlU0RT0iqttNY9LUrRAVWLYKshQtmEuEgKZ1lY=";
  duckdbBuildInputs = [ croaring ];
}
