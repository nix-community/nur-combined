{ config, nixosConfig, lib, pkgs, ... }:

{
  xdg.configFile = lib.mkIf nixosConfig.services.pipewire.wireplumber.enable {
    "pipewire/pipewire.conf.d/raop-discover.conf" = {
      text = ''
        context.modules = [
           {
               name = libpipewire-module-raop-discover
               args = { }
           }
        ]
      '';
    };
    "pipewire/pipewire.conf.d/zeroconf-discover.conf".text = ''
      context.modules = [
         {
             name = libpipewire-module-zeroconf-discover
             args = { }
         }
      ]
    '';
  };
}
