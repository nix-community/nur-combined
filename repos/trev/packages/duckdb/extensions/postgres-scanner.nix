{
  callPackage,
  libpq,
}:

(callPackage ./generic.nix { }) {
  name = "postgres_scanner";
  repo = "duckdb-postgres";
  branch = "v1.5-variegata";
  rev = "3d355bb632379f3de83952f8243b120ccc9f09c3";
  hash = "sha256-4WvUowG/SPhlFFq+ZvTmjgmH8ylx8zFYxdR/+tB/l9g=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ libpq ];
}
