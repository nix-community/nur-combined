let
  bindServiceModule = { lib, config, ... }: with lib; {
    options = {
      provides = mkOption {
        type = types.listOf types.str;
      };
    };
  };
  nixosModule = { commonRoot, pkgs, config, options, lib, ... }: with lib; {
    imports = [
      ./common-root.nix
    ];

    options = {
      networking = {
        enabledBindings = mkOption {
          type = with types; listOf unspecified;
          default = [ ];
        };
        bindings = mkOption {
          type = with types; attrsOf (submodule [
            ../misc/binding.nix
            commonRoot.tag
          ]);
        };
        domains = mkOption {
          type = with types; attrsOf (submodule [
            ../misc/domain.nix
            commonRoot.tag
            ({ ... }: {
              config._module.args = {
                inherit pkgs;
                nixosConfig = config;
              };
            })
          ]);
        };
      };
    };
    config = {
      networking = {
        bindings = { };
        domains = { };
        enabledBindings = let
          enabledDomains = filterAttrs (_: d: d.enable) config.networking.domains;
          enabledBindings = domain: filterAttrs (_: b: b.enable) domain.bindings;
          mapDomain = _: domain: attrValues (enabledBindings domain);
        in mkMerge (mapAttrsToList mapDomain enabledDomains);
      };
      networking.firewall = let
        externalBindings = filter (binding: binding.firewall.open) config.networking.enabledBindings;
        public' = partition (binding: binding.firewall.interfaces == null) externalBindings;
        public = public'.right;
        interfaces'' = concatMap (binding: map (interface: nameValuePair interface binding) binding.firewall.interfaces) public'.wrong;
        interfaces' = groupBy (b: b.name) interfaces'';
        interfaces = mapAttrs (_: map ({ name, value }: value)) interfaces';
        mapToAllowed = bindings: let
          tcp = partition (b: b.transport == "tcp") bindings;
        in {
          allowedTCPPorts = map (binding: binding.port) tcp.right;
          allowedUDPPorts = map (binding: binding.port) tcp.wrong;
        };
      in mapToAllowed public // {
        interfaces = mapAttrs (_: mapToAllowed) interfaces;
      };
    };
  };
in {
  services = import ./service-bindings.nix;

  __functor = self: nixosModule;
}
