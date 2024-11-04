{
  reIf,
  pkgs,
  config,
  ...
}:
reIf {
  services.garage = {
    enable = true;
    environmentFile = config.vaultix.secrets.garage.path;
    package = pkgs.garage;
    settings = {
      replication_factor = 1;
      db_engine = "lmdb";
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "127.0.0.1:3901";
      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.garage.localhost";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.garage.localhost";
        index = "index.html";
      };
      k2v_api.api_bind_addr = "[::]:3904";
      admin.api_bind_addr = "[::]:3903";
    };
  };
}
