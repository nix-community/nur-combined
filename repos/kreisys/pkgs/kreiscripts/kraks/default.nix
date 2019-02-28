{ mkBashCli, jq, nix }:

mkBashCli "kraks"
  ''
  aks kwestions. ugly one-liners that answer some painfully specific question.
  they tend to be scattered all over the harddrive, we don't want to delete them
  because we might need them some day, when we need them we can't find them etc.
  '' {} (mkCmd: [
  (mkCmd "nix" "aks nix. ask nix-related stuff" {} [
    (mkCmd "will-build-dependencies" "is this derivation gonna start recompiling the world and then fail because there's a reason those dependencies aren't in the binary cache? 🙃" {
      aliases   = [ "will-build-deps" "wbdeps" "wbd" ];
      options   = o: [ (o "f" "file" "default.nix" "file containing a nix expression") ];
    } ''
      ${nix}/bin/nix-build $FILE --dry-run "$@" 2>&1 | sed -n '/these paths will be fetched/q;p' | sed '1d; $d; s/^ *//' | wc -l | xargs -I% echo % derivations will be built
    '')
  ])
])

