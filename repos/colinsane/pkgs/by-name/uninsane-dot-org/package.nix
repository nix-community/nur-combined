{
  callPackage,
  fetchFromGitea,
  unstableGitUpdater,
}:
let
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "uninsane";
    rev = "760e3d6f08ee2b72dc21f73e99f483523de9cf62";
    hash = "sha256-fb7Maqi5i8i/30dS4MPEd/7rOUF8JEe7kAGBQlzuRTc=";
  };
  pkg = callPackage "${src}/default.nix" { };
in
  pkg.overrideAttrs (base: {
    inherit src;
    pname = "uninsane-dot-org";
    version = "0-unstable-2026-09-02";
    passthru = (base.passthru or {}) // {
      updateScript = unstableGitUpdater {
        shallowClone = false;  # shallowClone doesn't work with anubis
      };
    };
  })
