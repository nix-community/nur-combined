isNixos: { pkgs, config, lib, ... }: with lib; let
  config_ = config;
  cfg = config.keychain;
  activationScript = ''
    ${pkgs.coreutils}/bin/install -dm 0755 ${cfg.root}
    ${concatStringsSep "\n" (mapAttrsToList (_: f: ''
      ${pkgs.coreutils}/bin/install -Dm${f.mode} ${optionalString isNixos "-o${f.owner} -g${f.group}"} ${f.sourceFile} ${f.path}
    '') config.keychain.files)
    }
  '';
  fileType = types.submodule ({ name, config, ... }: {
    options = {
      source = mkOption {
        type = types.either types.path types.str;
      };
      sourceFile = mkOption {
        type = types.path;
        default = pkgs.lib.asPath "data" config.source;
      };
      owner = mkOption {
        type = types.str;
        default = if isNixos then "root" else config_.home.username;
      };
      group = mkOption {
        type = types.str;
        default = cfg.group;
      };
      mode = mkOption {
        type = types.str;
        default = "0400";
      };
      fileName = mkOption {
        type = types.str;
        default = name;
      };

      path = mkOption {
        type = types.path;
        internal = true;
      };
    };

    config.path = "${cfg.root}/${config.fileName}";
  });
  keyType = types.submodule ({ name, config, ... }: {
    options = {
      public = mkOption {
        type = types.either types.path types.str;
      };
      private = mkOption {
        type = types.nullOr (types.either types.path types.str);
        default = null;
      };
      fileName = mkOption {
        type = types.str;
        default = name;
      };

      path = {
        public = mkOption {
          type = types.path;
          internal = true;
        };
        private = mkOption {
          type = types.path;
          internal = true;
        };
      };
      content = {
        public = mkOption {
          type = types.str;
          internal = true;
        };
      };
    };

    config = {
      path = {
        public = pkgs.lib.asPath "id_rsa.pub" config.public;
        private = config_.keychain.files."key-${config.fileName}".path;
      };
      content.public = if pkgs.lib.isPath then builtins.readFile config.public else config.public;
    };
  });
in {
  options.keychain = {
    enable = mkOption {
      type = types.bool;
      default = cfg.files != { };
    };
    group = mkOption {
      type = types.nullOr types.str;
      default = if isNixos then "keys" else "users";
    };
    files = mkOption {
      type = types.attrsOf fileType;
      default = { };
    };
    keys = mkOption {
      type = types.attrsOf keyType;
      default = { };
    };
    root = mkOption {
      type = types.path;
      default = if isNixos
        then "/var/lib/arc/keychain"
        else "${config.xdg.cacheHome}/arc/keychain";
    };
  };

  config = let
    keyConfig = {
      keychain.files = mapAttrs' (name: key: nameValuePair "key-${name}" {
        source = key.private;
      }) (filterAttrs (_: k: k.private != null) cfg.keys);
    };
    activation = if isNixos then mkIf cfg.enable {
      system.activationScripts.arc_keychain = {
        text = activationScript;
        deps = [ "etc" ]; # must be done after passwd/etc are ready
      };

      users.groups.${cfg.group}.members = [ ];
    } else mkIf cfg.enable {
      home.activation.arc_keychain = config.lib.dag.entryAfter ["writeBoundary"] activationScript;
    };
  in mkMerge [ keyConfig activation ];
}
