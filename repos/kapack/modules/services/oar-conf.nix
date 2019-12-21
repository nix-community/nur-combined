{pkgs, cfg}:
{ oarBaseConf = pkgs.writeText "oar-base.conf" ''
#
# Database type ("mysql" or "Pg")
DB_TYPE="Pg"

test  ${cfg.package}
test prickey  ${cfg.privateKeyFile}
# DataBase hostname
DB_HOSTNAME="localhost"

# DataBase port
DB_PORT="5432"

# Database base name
DB_BASE_NAME="oar"

# DataBase user name
DB_BASE_LOGIN="oar"
  '';
}
