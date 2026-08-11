{
  pkgs,
  nixosModules,
  packages,
}:
{
  cascade = pkgs.testers.runNixOSTest {
    imports = [ ./cascade.nix ];
    nodes.machine = {
      imports = [ nixosModules.cascade ];
      services.cascade.package = packages.cascade;
    };
  };
  credentialsd = pkgs.testers.runNixOSTest {
    imports = [ ./credentialsd.nix ];
    nodes.machine = {
      imports = [ nixosModules.credentialsd ];
      services.credentialsd.package = packages.credentialsd;
    };
  };
}
