{
  getForgejoFlake,
  system,
}:
let
  base =
    (getForgejoFlake {
      url = "https://trev.zip/llc/shellHook";
      rev = "16cebcfac1912470fab83bae208bd06c1d75c8aa"; # v0.5.0
      hash = "sha256-bdQ7ahRIheRSKRAGIIsOh3bwFTY/+5M+q/ww9xwIXDk=";
    }).packages."${system}".default;
in
base.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./test-deadline.diff ];
})
