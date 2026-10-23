{ lib }:
let
  utils = import ../lib/hostUtils.nix { inherit lib; };
  # Inspect builder arguments without evaluating either operating system.
  inputs = {
    self = ../.;
    nixpkgs.lib = lib // {
      nixosSystem = args: args;
    };
    nix-darwin.lib.darwinSystem = args: args;
  };
  fixture =
    system:
    let
      device =
        (lib.evalModules {
          modules = [
            ../nixos/modules/device-options.nix
            {
              device = {
                inherit system;
                hostname = "fixture";
                users = [ "iamanaws" ];
              };
            }
          ];
        }).config.device;
    in
    {
      name = "fixture";
      # Intentionally has no options.nix: builders must use the supplied record.
      path = ./fixtures/profiles/defaulted;
      inherit device;
      inherit (device) users;
      hostConfig = utils.mkHostContext device;
    };
  linuxHost = fixture "x86_64-linux";
  darwinHost = fixture "aarch64-darwin";
  linux =
    import ../lib/mkNixos.nix
      {
        inherit inputs;
        outputs = { };
        userKeys = { };
      }
      {
        host = linuxHost;
      };
  darwin =
    import ../lib/mkDarwin.nix
      {
        inherit inputs;
        outputs = { };
      }
      {
        host = darwinHost;
      };
  usesRecord =
    host: system:
    let
      base = (builtins.head system.modules) { inherit lib; };
    in
    base.device == host.device
    && system.specialArgs.hostConfig == host.hostConfig
    && base.home-manager.extraSpecialArgs.hostConfig == host.hostConfig;
in
assert usesRecord linuxHost linux;
assert usesRecord darwinHost darwin;
# An omitted profile must actually select the schema's default profile module.
assert lib.elem ../nixos/profiles/server.nix linux.modules;
true
