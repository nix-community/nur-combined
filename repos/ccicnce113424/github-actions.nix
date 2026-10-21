{
  lib,
  self,
  inputs,
  ...
}:
let
  mkGithubMatrix =
    checks: attrPrefix:
    inputs.nix-github-actions.lib.mkGithubMatrix {
      inherit checks attrPrefix;
      platforms."x86_64-linux" = "ubuntu-latest";
    };
in
{
  flake.githubActions = {
    build = mkGithubMatrix (lib.filterAttrsRecursive (
      _: p: !(p.meta.broken or false)
    ) self.packages) "githubActions.build.checks";
    check = mkGithubMatrix self.checks "githubActions.check.checks";
  };
}
