{ ... }:

{
  security = {
    doas = {
      enable = true;
      extraRules = [
        {
          groups = [ "nixers" ];
          keepEnv = true;
          persist = true;
        }
      ];
    };
    sudo.enable = false;
  };
}
