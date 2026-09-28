{
  getForgejoFlake,
  system,
}:
let
  base =
    (getForgejoFlake {
      url = "https://trev.zip/llc/shellHook";
      rev = "3cce738fb316cb6c7996a212343c50ad48e0b69e"; # v0.3.0
      hash = "sha256-LHUMEjj8fxNlhP09BeujPauVi5v8a2jvkf5beEqm6mI=";
    }).packages."${system}".default;
in
base.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./test-deadline.diff ];
})
