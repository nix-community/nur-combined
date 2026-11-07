{
  getForgejoFlake,
  system,
}:
let
  base =
    (getForgejoFlake {
      url = "https://trev.zip/llc/shellHook";
      rev = "8aad8a43ee6c92ebd81d130bd1b555148d532b48"; # v0.4.0
      hash = "sha256-AjfCEkyM21Xfu8LzIMDjvvryKKmzAmIdQm0o3EbwQrs=";
    }).packages."${system}".default;
in
base.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./test-deadline.diff ];
})
