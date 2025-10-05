{
  lib,
  rustPlatform,
  fetchFromGitea,
}:

rustPlatform.buildRustPackage {
  pname = "gprox";
  version = "0-unstable-2024-07-07";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "reuse";
    repo = "gprox";
    rev = "eabed3e68850e61da8201c6b15f6a5454d0d8816";
    hash = "sha256-elSDOyTGOyLcMESCjKwabCCxE1PkpKxJzKnJyMUtwiA=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-PRpRZWxIMEikMDrS+jW/Uecha9Onuq6mn9CaK+i7GJs=";

  meta = {
    description = "Tool to process .gpx files";
    homepage = "https://codeberg.org/reuse/gprox";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "gprox";
  };
}
