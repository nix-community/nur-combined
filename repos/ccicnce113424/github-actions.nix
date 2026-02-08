{
  self,
  inputs,
  ...
}:
{
  flake.githubActions.build = inputs.nix-github-actions.lib.mkGithubMatrix {
    checks = self.packages;
    attrPrefix = "githubActions.build.checks";
    platforms."x86_64-linux" = "ubuntu-latest";
  };
}
