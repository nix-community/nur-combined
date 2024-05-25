{ config, user, ... }:
{
  enable = true;
  originalsPath = "/var/lib/private/photoprism/originals";
  address = "[::]";
  passwordFile = config.age.secrets.prism.path;
  settings = {
    PHOTOPRISM_ADMIN_USER = "${user}";
    PHOTOPRISM_DEFAULT_LOCALE = "en";
    PHOTOPRISM_DATABASE_NAME = "photoprism";
    PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
    PHOTOPRISM_DATABASE_USER = "photoprism";
    PHOTOPRISM_DATABASE_DRIVER = "mysql";
  };
  port = 20800;
}
