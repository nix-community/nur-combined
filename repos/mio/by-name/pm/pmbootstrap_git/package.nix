{
  pmbootstrap,
  fetchFromGitLab,
}:

let
  src = fetchFromGitLab {
    owner = "nura";
    repo = "pmbootstrap";
    rev = "e0dfe2cda7f3a0b70cdcc96f3060100839322aa4";
    hash = "sha256-MvFowTC6QKPsLOrkwWhfUegXf6Y5rmuqZwyn/tO//vg=";
    domain = "gitlab.nura.eco";
  };
in

pmbootstrap.overrideAttrs (oldAttrs: {
  version = "3.12.1-unstable-2026-11-02";

  inherit src;

  # pmb_test was expanded from the original source; point it at the new one.
  pmb_test = "${src}/test";

  # The source still reports the release version (3.12.1), which does not
  # match the -unstable suffix.
  dontVersionCheck = true;

  # The update script tracks release tags, not this revision.
  passthru = builtins.removeAttrs (oldAttrs.passthru or { }) [ "updateScript" ];
})
