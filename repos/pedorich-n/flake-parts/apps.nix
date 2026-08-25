{
  self,
  ...
}:
{
  perSystem =
    {
      system,
      pkgs,
      ...
    }:
    {
      apps = {
        nur-readme-update = {
          type = "app";
          program = pkgs.callPackage ../dev/pkgs/nur-readme-update {
            flake = self;
            inherit system;
          };
        };
      };
    };
}
