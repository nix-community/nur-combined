{
  flake.modules.nixos.realm =
    { config, lib, ... }:
    {
      # Isolated workloads opt in automatically. The laptop remains excluded.
      realm.agent.enable = lib.mkDefault (config.networking.hostName != "kaambl");
    };
}
