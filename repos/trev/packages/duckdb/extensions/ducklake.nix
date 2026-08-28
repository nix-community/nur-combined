{
  callPackage,
  croaring,
}:

(callPackage ./generic.nix { }) {
  name = "ducklake";
  repo = "ducklake";
  branch = "v1.5-variegata";
  rev = "2feb1a031c40b8b1fed3a48b14e0286ae37f67b2";
  hash = "sha256-hbehL6e4wDSHMkPBgm7DVTGzQZw3M0f6HJmVR595dD4=";
  duckdbBuildInputs = [ croaring ];
}
