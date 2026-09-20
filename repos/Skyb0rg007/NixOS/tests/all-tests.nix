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
  keylime = pkgs.testers.runNixOSTest {
    imports = [ ./keylime.nix ];
    node.specialArgs = {
      inherit (packages) rust-keylime;
    };
    nodes.machine = {
      imports = [ nixosModules.keylime ];
      services.keylime.package = packages.keylime;
    };
  };
  credentialsd = pkgs.testers.runNixOSTest {
    imports = [ ./credentialsd.nix ];
    nodes.machine = {
      imports = [ nixosModules.credentialsd ];
      services.credentialsd.package = packages.credentialsd;
    };
  };
  ublksrv = pkgs.testers.runNixOSTest {
    imports = [ ./ublksrv.nix ];
    nodes = {
      open = {
        imports = [ nixosModules.ublksrv ];
        programs.ublksrv.package = packages.ublksrv;
      };
      restricted = {
        imports = [ nixosModules.ublksrv ];
        programs.ublksrv.package = packages.ublksrv;
      };
    };
  };
}
