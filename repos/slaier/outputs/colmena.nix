{ super, inputs, ... }:
{
  meta = {
    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
    };
  };
  defaults = { name, config, ... }: {
    deployment.targetHost = with config.services.avahi; "${hostName}.${domainName}";
    deployment.allowLocalDeployment = true;
  };
} // builtins.mapAttrs
  (name: value: {
    imports = value._module.args.modules;
  })
  super.nixosConfigurations
