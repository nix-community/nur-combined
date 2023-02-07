{ vlanConfig, ... }: {
  networking.vlans.${vlanConfig.name} = { inherit (vlanConfig) interface id; };
  networking.interfaces.${vlanConfig.name}.useDHCP = true;
}
