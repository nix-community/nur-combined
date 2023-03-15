_: {
  services.prometheus = {
    rules = [ ];
    enable = true;
    extraFlags = [ ];
    globalConfig = { };
    enableReload = true;
    retentionTime = "15d";
    alertmanagers = [ ];
  };
}
