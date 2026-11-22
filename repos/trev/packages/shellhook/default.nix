{
  getForgejoFlake,
  system,
}:
let
  base =
    (getForgejoFlake {
      url = "https://trev.zip/llc/shellHook";
      rev = "7b25d890916e8139eee5bce933e0aef8e1ada0ae"; # v0.7.0
      hash = "sha256-1/u4YOs89GXP1fb3iVZV5hZVhdPVYRReXgc2QsmFbf4=";
    }).packages."${system}".default;
in
base.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./test-deadline.diff ];
})
