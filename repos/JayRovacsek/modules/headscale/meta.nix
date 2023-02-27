{ config, pkgs, lib, ... }:
let
  unixEpoch = "'1970-01-01 00:00:00.000000000+00:00'";
  futureMeProblem = "'2050-01-01 00:00:00.000000000+00:00'";

  preauthKeys = builtins.filter (x: lib.strings.hasPrefix "preauth-" x.name)
    (builtins.attrValues config.age.secrets);

  # The namespace table was renamed to users; see also:
  # https://github.com/juanfont/headscale/blob/main/docs/glossary.md
  users =
    lib.lists.map (v: lib.strings.removePrefix "preauth-" v.name) preauthKeys;

  # CREATE TABLE IF NOT EXISTS "users" (`id` integer,`created_at` datetime,`updated_at` datetime,`deleted_at` datetime,`name` text UNIQUE,PRIMARY KEY (`id`));
  usersInsertStatements = builtins.concatStringsSep "\n" (lib.lists.imap1 (i: v:
    "INSERT INTO users ('id','created_at','updated_at','name') VALUES (${
      builtins.toString i
    }, ${unixEpoch},${unixEpoch},'${
      lib.strings.removePrefix "preauth-" v.name
    }');") preauthKeys);

  # CREATE TABLE `pre_auth_keys` (`id` integer,`key` text,"user_id" integer,`reusable` numeric,`ephemeral` numeric DEFAULT false,`used` numeric DEFAULT false,`created_at` datetime,`expiration` datetime,PRIMARY KEY (`id`));
  preauthInsertStatements = builtins.concatStringsSep "\n" (lib.lists.imap1
    (i: v:
      "INSERT INTO pre_auth_keys ('id','key','user_id','reusable','ephemeral','used','created_at','expiration') VALUES (${
        builtins.toString i
      },'`cat ${v.path}`',${
        builtins.toString i
      },1,0,0,${unixEpoch},${futureMeProblem});") preauthKeys);

  # Okay, so the below is straigh pain to decipher, this is likely due to my nix 
  # capabilities but translates as follows:
  # * read the contents of our secrets directory, grabbing all file names
  # * where the filename starts with "preauth-"
  # * map keys to a structure of ("name" minus ".age") = set representing agenix config
  #
  # So yeah, not pretty but scales to pull in all secrets that include the 
  # "preauth-" value so we can generate entries into sqlite on every rebuild
  secrets = builtins.foldl' (a: b: a // b) { } (builtins.map (x: {
    "${lib.strings.removeSuffix ".age" x}" = {
      file = ../../secrets/tailscale/${x};
      mode = "0400";
      owner = config.services.headscale.user;
    };
  }) (builtins.filter (z: (lib.strings.hasSuffix ".age" z))
    (builtins.attrNames (builtins.readDir ../../secrets/tailscale))));

  # The delete from all tables below could probably be done better but I can't DB :)
  # It's required to ensure we have a blank slate moving in and no residual state can be 
  # left behind causing issues later
  sqlStatement = ''
    delete from users;
    delete from pre_auth_keys;
    delete from machines;
    delete from kvs;
    delete from api_keys;

    ${usersInsertStatements}

    ${preauthInsertStatements}
  '';

  script = with pkgs; ''
    bash -c "
    sqlite3 ${config.services.headscale.database.path} <<'END_SQL'

    ${sqlStatement}

    END_SQL"
  '';

  cfg = { inherit users preauthKeys secrets script; };
in cfg
