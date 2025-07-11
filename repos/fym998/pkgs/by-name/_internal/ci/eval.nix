{ writeShellApplication, nix-eval-jobs }:
writeShellApplication {
  name = "eval";

  runtimeInputs = [
    nix-eval-jobs
  ];

  text = "nix-eval-jobs --flake .#ciPackages --force-recurse";
}
