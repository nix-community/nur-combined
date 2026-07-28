{ ... }: {
  services.couchdb = {
    enable = true;
    adminPass = "admin";
    extraConfig = {
      couchdb = {
        enable_database_recovery = true;
        single_node = true;
      };
    };
  };
}
