{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "343df36a33954f40c8a92fd4b6d46a25577dd98e";
  hash = "sha256-jzGETxMiQpkaYMxI90p95qTqLfIi/zEg52iwXHWnXBg=";
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ croaring ];
}
