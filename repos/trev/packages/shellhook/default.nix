{
  getForgejoFlake,
  system,
}:
let
  base =
    (getForgejoFlake {
      url = "https://trev.zip/llc/shellHook";
      rev = "f012c840510327e046ed66b68db55733859b4ec3"; # v0.6.0
      hash = "sha256-IbWz43G8jDi09Z1AFTUM5MKBx6nAB8KmZ7H3Rs6MbR4=";
    }).packages."${system}".default;
in
base.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./test-deadline.diff ];
})
