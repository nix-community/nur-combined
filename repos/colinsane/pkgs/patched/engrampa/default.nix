{ mate
, fetchFromGitHub
, lib
}:
mate.engrampa.overrideAttrs (super: {
  pname = "engrampa-sane";
  src = lib.warnIf (super.version != "1.26.1") "engrampa package pin is outdated" (fetchFromGitHub {
    owner = "mate-desktop";
    repo = "engrampa";
    # point to a version > 1.27.0, for working cross compilation.
    # remove this override once engrampa > 1.27.0 is released.
    rev = "45f52c13baa93857d912effb4f1f9a58c41a0da3";
    hash = "sha256-j7tASMjBSA+d1a9Fu3G/328aRDqNJjXoITxogRH0YI4=";
  });
})
