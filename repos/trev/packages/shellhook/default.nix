{
  getForgejoFlake,
  system,
}:
let
  base =
    (getForgejoFlake {
      url = "https://trev.zip/llc/shellHook";
      rev = "48ca9bd5c7dd6a108c0c95374364190ecc48f24b"; # v0.3.2
      hash = "sha256-wjz7u627tlCYMXP/S6WtLibEQmA1ybpglqql8+fdDuc=";
    }).packages."${system}".default;
in
base.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./test-deadline.diff ];
})
