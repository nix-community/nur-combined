{
  getForgejoFlake,
  system,
}:
let
  base =
    (getForgejoFlake {
      url = "https://trev.zip/llc/shellHook";
      rev = "f4966180ea02e6cce3067a952aa5cea237c5791d"; # v0.3.1
      hash = "sha256-ACfqbYRLAqLIZ9ZWD0zm0ac311D2US+kHWY8qUpL9UY=";
    }).packages."${system}".default;
in
base.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./test-deadline.diff ];
})
