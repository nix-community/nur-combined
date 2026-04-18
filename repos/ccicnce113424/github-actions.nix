{
  lib,
  self,
  inputs,
  ...
}:
{
  flake.githubActions.build = inputs.nix-github-actions.lib.mkGithubMatrix {
    checks = lib.filterAttrsRecursive (_: p: !(p.meta.broken or false)) self.packages;
    attrPrefix = "githubActions.build.checks";
    platforms."x86_64-linux" = "ubuntu-latest";
  };
}
