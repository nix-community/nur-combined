{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
    checks = lib.recursiveUpdate self.packages self.checks;
    platforms."x86_64-linux" = "ubuntu-latest";
  };
}
