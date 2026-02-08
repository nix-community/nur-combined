{
  self,
  inputs,
  ...
}:
{
  flake.githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
    checks = self.packages;
    platforms."x86_64-linux" = "ubuntu-latest";
  };
}
