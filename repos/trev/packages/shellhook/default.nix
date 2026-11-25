{
  getForgejoFlake,
  system,
}:
let
  base =
    (getForgejoFlake {
      url = "https://trev.zip/llc/shellHook";
      rev = "68da98ff099385e21e6440464e93017513a7be36"; # v0.8.0
      hash = "sha256-i2zvQf4ScyMPE7bgBecr74xSskipkp2YyXrKcYxWX8E=";
    }).packages."${system}".default;
in
base.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./test-deadline.diff ];
})
