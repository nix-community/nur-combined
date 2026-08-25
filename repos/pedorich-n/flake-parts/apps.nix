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
        nur-readme-generator = {
          type = "app";
          program = pkgs.callPackage ../dev/pkgs/nur-readme-generator {
            flake = self;
            inherit system;
          };
        };
      };
    };
}
