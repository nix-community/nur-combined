{
  reIf,
  config,
  user,
  ...
}:
reIf {
  services.photoprism = {
    enable = true;
    originalsPath = "/var/lib/private/photoprism/originals";
    address = "[::]";
    passwordFile = config.age.secrets.wg.path;
    settings = {
      PHOTOPRISM_ADMIN_USER = "prism";
      PHOTOPRISM_DEFAULT_LOCALE = "en";
      PHOTOPRISM_DATABASE_NAME = "photoprism";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "photoprism";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
    };
    port = 20800;
  };
}
