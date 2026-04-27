{
  nixosModules = {
    daed = {
      disabledModules = [ "services/networking/daed.nix" ];
      imports = [ ./daed.nix ];
    };
  };
}
