{ lib, buildGoModule, callPackage, fetchFromGitHub, fetchpatch }:
let
  common = callPackage ./common.nix { };
in
buildGoModule {
  pname = "woodpecker-agent";
  inherit (common) version src ldflags postInstall vendorHash;

  patches = [
    # https://github.com/woodpecker-ci/woodpecker/pull/1686
    (fetchpatch {
      name = "fix-local-pipeline-home.patch";
      url = "https://github.com/woodpecker-ci/woodpecker/commit/d2c9b73ebf015bfa64062b9855c33e14484ccc3e.patch";
      hash = "sha256-1wYe4+oCWiV/6W4cIbdDT+mEL9ETQmcYQZhjJASvmUk=";
    })
  ];

  subPackages = "cmd/agent";

  CGO_ENABLED = 0;

  meta = common.meta // {
    description = "Woodpecker Continuous Integration agent";
  };
}
