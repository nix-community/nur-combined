{ config, pkgs, lib, ... }: {

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "sslmate-agent"
  ];
  services.sslmate-agent = {
    enable = true;
    apiKey = "test";
    apiEndpoint = "test";
    refreshInterval = "5m";
    onUpdateEnvVars = true;
    clusters = {
      "testing".secret = "test";
      "testing2".secret = "teste";
    };
    defaultOrders = {
      keyUser = "bjorn";   
    };
    orders = {
      "testingorder" = {
        keyPerm = "0644";
        temp = true;
      };
      "anothertestingorder" = {
        keyGroup = "wheel";
        onUpdate = [ "systemctl restart jenkins" "systemctl restart nginx" ];
      };
    };
  };
}
