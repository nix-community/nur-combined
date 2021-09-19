{ lib, config, pkgs, ... }: with lib; let
  cfg = config.services.wireplumber;
  arc = import ../../canon.nix { inherit pkgs; };
  lua = lib.lua or arc.lib.lua;
  json = lib.json or arc.lib.json;
  migrateAlsa = listToAttrs (imap1 (i: rule: nameValuePair "mediaSession${toString i}" {
    matches = map (mapAttrsToList (subject: comparison: {
      inherit subject comparison;
      verb = "matches";
    })) rule.matches;
    apply = rule.actions.update-props or { };
  }) config.services.pipewire.media-session.config.alsa-monitor.rules or [ ]);
  luaComponent = component: luaComponents {
    name = "wireplumber-${component.name}";
    components = singleton component;
  };
  luaComponents = {
    name ? "wireplumber.lua"
  , components
  }: let
    componentsConfig = listToAttrs (imap1 (i: comp: nameValuePair "${fixedWidthNumber 3 i}${comp.name}" comp.out.lua) components);
  in pkgs.writeText "${name}" ''
    components = ${lua.serializeExpr componentsConfig}
  '';
  pipewireModuleArgs = json.types.attrs;
  pipewireModuleType = types.submodule ({ config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
      };
      arguments = mkOption {
        type = pipewireModuleArgs;
        default = { };
      };
      flags = {
        ifexists = mkOption {
          type = types.bool;
          default = false;
        };
        nofail = mkOption {
          type = types.bool;
          default = false;
        };
      };
      out = {
        context = mkOption {
          type = types.attrs;
          internal = true;
        };
        component = mkOption {
          type = types.attrs;
          internal = true;
        };
        lua = mkOption {
          type = types.attrs;
          internal = true;
        };
      };
    };
    config.out = {
      context = {
        inherit (config) name;
        args = config.arguments;
        flags = mapAttrsToList (k: _: k) (
          filterAttrs (_: flag: flag) config.flags
        );
      };
      component = {
        inherit (config) name;
        type = "pw_module";
        # TODO: assert that args and flags are empty because they are not yet supported
      };
      lua = lua.toTable [ config.name ] // {
        # TODO: assert flags are empty
        type = "pw_module";
        args = config.arguments;
      };
    };
  });
  wireplumberModuleType = types.submodule ({ config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
      };
      arguments = mkOption {
        type = types.nullOr pipewireModuleArgs;
        default = null;
      };
      type = mkOption {
        type = types.enum [ "module" "pw_module" "script/lua" "config/lua" ];
        default = "module";
      };
      out = {
        component = mkOption {
          type = types.attrs;
          internal = true;
        };
        lua = mkOption {
          type = types.attrs;
          internal = true;
        };
      };
    };
    config.out = {
      component = {
        inherit (config) name type;
        # TODO: assert that args are empty because they are not yet supported
      };
      lua = lua.toTable [ config.name ] // {
        inherit (config) type;
      } // optionalAttrs (config.arguments != null) {
        args = config.arguments;
      };
    };
  });
  pipewireModuleTypeSloppy = with types; coercedTo str (name: { inherit name; }) pipewireModuleType;
  pipewireContextType = with types; oneOf [ bool int str (attrsOf pipewireContextType) (listOf pipewireContextType) ];
  policyRoleType = types.submodule ({ name, config, ... }: {
    options = {
      enable = mkEnableOption "role";
      name = mkOption {
        type = types.str;
        default = name;
      };
      aliases = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      priority = mkOption {
        type = types.int;
        default = 0;
      };
      actions = mkOption {
        type = with types; attrsOf str;
        default = { };
      };
      endpoint = {
        enable = mkEnableOption "role endpoint" // { default = true; };
        name = mkOption {
          type = types.str;
          default = name;
        };
        class = mkOption {
          type = types.str;
          default = "Audio/Sink";
        };
      };
    };
  });
  constraintType = types.submodule ({ config, options, ... }: let
    valuelessVerbs = [ "is-present" "is-absent" ];
    values = [ config.subject config.verb ] ++ config.values;
    valuesWithType = lua.toTable values // {
      inherit (config) type;
    };
    defaultVerb =
      if options.comparison.isDefined then "matches"
      else if options.inList.isDefined then "in-list"
      else if options.range.min.isDefined || options.range.max.isDefined then "in-range"
      else "is-present";
    defaultValues = verbs.${config.verb}.values;
    verbs = {
      equals = {
        char = "=";
        values = singleton config.comparison;
      };
      not-equals = {
        char = "!";
        inherit (verbs.equals) values;
      };
      matches = {
        char = "#";
        inherit (verbs.equals) values;
      };
      in-list = {
        char = "c";
        values = config.inList;
      };
      in-range = {
        char = "~";
        values = [ config.range.min config.range.max ];
      };
      is-present = {
        char = "+";
        values = [ ];
      };
      is-absent = {
        char = "-";
        inherit (verbs.is-present) values;
      };
    };
    verbChars = mapAttrs' (name: { char, ... }: nameValuePair char name) verbs;
  in {
    options = {
      subject = mkOption {
        type = types.str;
      };
      comparison = mkOption {
        type = json.type;
      };
      inList = mkOption {
        type = types.listOf json.type;
      };
      range = {
        min = mkOption {
          type = json.type;
        };
        max = mkOption {
          type = json.type;
        };
      };
      values = mkOption {
        type = types.listOf json.type;
        default = defaultValues;
      };
      verb = mkOption {
        type = with types; coercedTo (enum (attrNames verbChars)) (c: verbChars.${c}) (enum (attrValues verbChars));
        default = defaultVerb;
      };
      type = mkOption {
        type = types.enum [ "none" "pw-global" "pw" "gobject" ];
        default = "none";
      };

      out = {
        properties = mkOption {
          type = types.unspecified;
          default = if config.type != "none" then valuesWithType else values;
        };
      };
    };
  });
  orConstraints = with types; let
    singleOr = ty: coercedTo attrs singleton (listOf ty);
  in singleOr (singleOr constraintType);
  mapMatches = map (map (constraint: constraint.out.properties));
  mapRulesToLua = rules: mapAttrsToList (_: rule: rule.out.properties) (filterAttrs (_: r: r.enable) rules);
  alsaRuleType = types.submodule ({ config, ... }: {
    options = {
      enable = mkEnableOption "rule" // { default = true; };
      matches = mkOption {
        type = orConstraints;
      };
      apply = mkOption {
        type = types.attrsOf json.type;
        default = { };
      };
      out = {
        properties = mkOption {
          type = types.unspecified;
        };
      };
    };
    config.out.properties = {
      matches = mapMatches config.matches;
      apply_properties = config.apply;
    };
  });
  accessRuleType = types.submodule ({ config, ... }: {
    options = {
      enable = mkEnableOption "rule" // { default = true; };
      matches = mkOption {
        type = orConstraints;
      };
      permissions = mkOption {
        type = types.str;
      };
      out = {
        properties = mkOption {
          type = types.unspecified;
        };
      };
    };
    config.out.properties = {
      matches = mapMatches config.matches;
      default_permissions = config.permissions;
    };
  });
in {
  options.services.wireplumber = {
    enable = mkEnableOption "wireplumber";
    package = mkOption {
      type = types.package;
      default = pkgs.wireplumber or arc.packages.wireplumber;
      defaultText = "pkgs.wireplumber";
    };
    service = {
      dataDir = mkOption {
        type = types.path;
      };
      dataDirPaths = mkOption {
        type = with types; listOf path;
      };
      configFile = mkOption {
        type = types.path;
        internal = true;
      };
    };
    logLevel = mkOption {
      type = types.int;
      default = 2;
    };
    lua = {
      enable = mkEnableOption "lua scripting engine" // { default = true; };
    };
    access = {
      enable = mkEnableOption "default access module" // { default = true; };
      enableFlatpakPortal = mkOption {
        type = types.bool;
        default = true;
      };
      rules = mkOption {
        type = types.attrsOf accessRuleType;
        default = { };
      };
    };
    defaults = {
      enable = mkEnableOption "Track/store/restore user choices about devices" // {
        default = true;
      };
      persistent = mkEnableOption "store preferences to the file system and restore them at startup" // {
        default = true;
      };
      properties = mkOption {
        type = json.types.attrs;
      };
    };
    policy = {
      enable = mkEnableOption "policy" // { default = true; };
      session = {
        move = mkOption {
          type = types.bool;
          default = true;
        };
        follow = mkOption {
          type = types.bool;
          default = true;
        };
      };
      duck = {
        level = mkOption {
          type = types.float;
          default = 0.3;
        };
      };
      roles = {
        role = mkOption {
          type = with types; attrsOf policyRoleType;
        };
        endpointsProperties = mkOption {
          type = json.types.attrs;
        };
        properties = mkOption {
          type = json.types.attrs;
        };
      };
      properties = mkOption {
        type = json.types.attrs;
      };
    };
    alsa = {
      enable = mkEnableOption "Load alsa device monitor" // { default = true; };
      migrateMediaSession = mkOption {
        type = types.bool;
        default = false;
      };
      reserve = {
        enable = mkEnableOption "Device reservation" // { default = true; };
        priority = mkOption {
          type = types.int;
          default = -20;
        };
        name = mkOption {
          type = types.str;
          default = "WirePlumber";
        };
      };
      midi = {
        enable = mkEnableOption "MIDI" // { default = true; };
        monitoring = mkEnableOption "monitoring of alsa MIDI devices" // { default = true; };
        properties = mkOption {
          type = json.types.attrs;
          default = { };
        };
      };
      properties = mkOption {
        type = json.types.attrs;
        default = { };
      };
      rules = mkOption {
        type = types.attrsOf alsaRuleType;
      };
    };
    v4l2 = {
      enable = mkEnableOption "Load v4l2 device monitor";
    };
    bluez = {
      enable = mkEnableOption "Load bluetooth device monitor";
    };
    intended-roles.enable = mkEnableOption ''
      Link nodes by stream role and device intended role
    '' // { default = true; };
    suspend-node.enable = mkEnableOption ''
      Automatically suspends idle nodes after 3 seconds
    '' // { default = true; };
    device-activation.enable = mkEnableOption ''
      Automatically sets device profiles to 'On'
    '' // { default = true; };
    pipewire = {
      modules = mkOption {
        type = types.listOf pipewireModuleTypeSloppy;
      };
      spaLibs = mkOption {
        type = with types; attrsOf str;
      };
      rt = {
        enable = mkEnableOption "rt";
        nice = mkOption {
          type = types.int;
          default = -11;
        };
        priority = mkOption {
          type = types.int;
          default = 88;
        };
        limit = {
          soft = mkOption {
            type = types.int;
            default = 2000000;
          };
          hard = mkOption {
            type = types.int;
            default = cfg.pipewire.rt.limit.soft;
          };
        };
      };
    };
    scripts = mkOption {
      type = with types; attrsOf lines;
      default = { };
    };
    components = mkOption {
      type = types.listOf wireplumberModuleType;
    };
    config = mkOption {
      type = with types; attrsOf (either (attrsOf pipewireContextType) (listOf pipewireContextType));
    };
    moduleDir = mkOption {
      type = with types; nullOr path;
      default = null;
    };
  };

  config = {
    services.wireplumber = {
      service = {
        configFile = pkgs.writeText "wireplumber.conf" (builtins.toJSON cfg.config);
        dataDir = mkOptionDefault "${pkgs.symlinkJoin {
          name = "wireplumber-data";
          paths = cfg.service.dataDirPaths;
        }}";
        dataDirPaths = singleton "${cfg.package}/share/wireplumber"
        ++ mapAttrsToList (name: pkgs.writeText "scripts/${name}") cfg.scripts;
      };
      pipewire = {
        modules = mkMerge [
          (mkIf cfg.pipewire.rt.enable (mkBefore [
            {
              name = "libpipewire-module-rtkit";
              args = let inherit (cfg.pipewire) rt; in {
                "nice.level" = rt.nice;
                "rt.prio" = rt.priority;
                "rt.time.soft" = rt.limit.soft;
                "rt.time.hard" = rt.limit.hard;
              };
            }
          ]))
          (mkBefore [
            { name = "libpipewire-module-protocol-native"; }
            { name = "libpipewire-module-client-node"; }
            { name = "libpipewire-module-client-device"; }
            { name = "libpipewire-module-adapter"; }
            { name = "libpipewire-module-metadata"; }
          ])
          [
            { name = "libpipewire-module-session-manager"; }
          ]
        ];
        spaLibs = mapAttrs (_: mkOptionDefault) {
          "api.alsa.*" = "alsa/libspa-alsa";
          "api.bluez5.*" = "bluez5/libspa-bluez5";
          "api.v4l2.*" = "v4l2/libspa-v4l2";
          "api.libcamera.*" = "libcamera/libspa-libcamera";
          "audio.convert.*" = "audioconvert/libspa-audioconvert";
          "support.*" = "support/libspa-support";
        };
      };
      access.rules.flatpak = {
        matches = mkOptionDefault {
          subject = "pipewire.access";
          comparison = "flatpak";
          verb = "=";
        };
        permissions = mkOptionDefault "rx";
      };
      defaults.properties = mapAttrs (_: mkOptionDefault) {
        "use-persistent-storage" = cfg.defaults.persistent;
      };
      policy = {
        properties = mapAttrs (_: mkOptionDefault) {
          move = cfg.policy.session.move;
          follow = cfg.policy.session.follow;
          "duck.level" = cfg.policy.duck.level;
        } // {
          roles = cfg.policy.roles.properties;
        };
        roles = {
          role = {
            multimedia = mapAttrs (_: mkDefault) {
              name = "Multimedia";
              aliases = [ "Movie" "Music" "Game" ];
              priority = 10;
            } // {
              actions.default = mkOptionDefault "mix";
            };
            notification = mapAttrs (_: mkDefault) {
              name = "Notification";
              endpoint.name = "notifications";
              priority = 20;
            } // {
              actions = mapAttrs (_: mkOptionDefault) {
                default = "duck";
                Notification = "mix";
              };
            };
            alert = mapAttrs (_: mkDefault) {
              name = "Alert";
              priority = 30;
            } // {
              actions = mapAttrs (_: mkOptionDefault) {
                default = "cork";
                Alert = "mix";
              };
            };
          };
          endpointsProperties = mapAttrs' (_: role: nameValuePair "endpoint.${role.endpoint.name}" (mkIf (role.enable && role.endpoint.enable) {
            "media.class" = mkOptionDefault role.endpoint.class;
            role = role.name;
          })) cfg.policy.roles.role;
          properties = mapAttrs' (_: role: nameValuePair role.name (mkIf role.enable (
            mapAttrs' (key: action: nameValuePair "action.${key}" action) role.actions
            // {
              alias = mkIf (role.aliases != [ ]) role.aliases;
              priority = mkOptionDefault role.priority;
            }
          ))) cfg.policy.roles.role;
        };
      };
      alsa = {
        properties = mapAttrs (_: mkOptionDefault) {
          "alsa.reserve" = cfg.alsa.reserve.enable;
          "alsa.reserve.priority" = cfg.alsa.reserve.priority;
          "alsa.reserve.application-name" = cfg.alsa.reserve.name;
        };
        midi.properties = mapAttrs (_: mkOptionDefault) {
          "alsa.midi.monitoring" = cfg.alsa.midi.monitoring;
        };
        rules = mkMerge [ {
          defaultCardProfile = {
            matches = mkOptionDefault {
              subject = "device.name";
              comparison = "alsa_card.*";
            };
            apply = mapAttrs (_: mkOptionDefault) {
              "api.alsa.use-acp" = true;
              "api.acp.auto-profile" = false;
              "api.acp.auto-port" = false;
            };
          };
        } (mkIf cfg.alsa.migrateMediaSession migrateAlsa) ];
      };
      components = let
        access = singleton {
          name = "access/access-default.lua";
          type = "script/lua";
          arguments = {
            rules = mapRulesToLua cfg.access.rules;
          };
        } ++ optionals cfg.access.enableFlatpakPortal [
          { name = "libwireplumber-module-portal-permissionstore"; type = "module"; }
          { name = "access/access-portal.lua"; type = "script/lua"; }
        ];
        defaults = [
          { name = "libwireplumber-module-default-nodes"; type = "module"; arguments = cfg.defaults.properties; }
          { name = "default-routes.lua"; type = "script/lua"; arguments = cfg.defaults.properties; }
        ] ++ optionals cfg.defaults.persistent [
          { name = "libwireplumber-module-default-profile"; type = "module"; }
          { name = "restore-stream.lua"; type = "script/lua"; }
        ];
        policy = [
          { name = "libwireplumber-module-si-node"; type = "module"; }
          { name = "libwireplumber-module-si-audio-adapter"; type = "module"; }
          { name = "libwireplumber-module-si-standard-link"; type = "module"; }
          { name = "libwireplumber-module-si-audio-endpoint"; type = "module"; }
          { name = "libwireplumber-module-default-nodes-api"; type = "module"; } # access default nodes from scripts
          { name = "libwireplumber-module-mixer-api"; type = "module"; } # needed for volume ducking
          { name = "static-endpoints.lua"; type = "script/lua"; arguments = cfg.policy.roles.endpointsProperties; }
          { name = "create-item.lua"; type = "script/lua"; }
          { name = "policy-node.lua"; type = "script/lua"; arguments = cfg.policy.properties; }
          { name = "policy-endpoint-client.lua"; type = "script/lua"; arguments = cfg.policy.properties; }
          { name = "policy-endpoint-client-links.lua"; type = "script/lua"; arguments = cfg.policy.properties; }
          { name = "policy-endpoint-device.lua"; type = "script/lua"; arguments = cfg.policy.properties; }
        ];
        alsa =
          optional cfg.alsa.reserve.enable { name = "libwireplumber-module-reserve-device"; type = "module"; }
          ++ optional cfg.alsa.midi.monitoring { name = "libwireplumber-module-file-monitor-api"; type = "module"; }
          ++ singleton { name = "monitors/alsa.lua"; type = "script/lua"; arguments = {
            properties = cfg.alsa.properties;
            rules = mapRulesToLua cfg.alsa.rules;
          }; }
          ++ optional cfg.alsa.midi.enable { name = "monitors/alsa-midi.lua"; type = "script/lua"; arguments = {
            properties = cfg.alsa.midi.properties;
          }; };
        v4l2 = throw "TODO";
        bluez = throw "TODO";
      in mkMerge [
        (mkBefore (
          optionals cfg.access.enable access
        ))
        (
          optionals cfg.alsa.enable alsa
          ++ optionals cfg.v4l2.enable v4l2
          ++ optionals cfg.bluez.enable bluez
        )
        (mkAfter (
          optionals cfg.defaults.enable defaults
          ++ optional cfg.intended-roles.enable {
            name = "intended-roles.lua"; type = "script/lua";
          }
          ++ optional cfg.suspend-node.enable {
            name = "suspend-node.lua"; type = "script/lua";
          }
          ++ optional cfg.device-activation.enable {
            name = "libwireplumber-module-device-activation"; type = "module";
          } ++ optionals cfg.policy.enable policy
        ))
      ];
      config = {
        "context.properties" = {
          "log.level" = mkOptionDefault cfg.logLevel;
          "wireplumber.script-engine" = mkIf cfg.lua.enable (mkOptionDefault "lua-scripting");
        };
        "context.spa-libs" = mapAttrs (_: mkOptionDefault) cfg.pipewire.spaLibs;
        "context.modules" = map (mod: mod.out.context) cfg.pipewire.modules;
        "wireplumber.components" = let
          prelude =
            optional cfg.lua.enable { name = "libwireplumber-module-lua-scripting"; type = "module"; }
            ++ singleton { name = "libwireplumber-module-metadata"; type = "module"; };
          # XXX: until wp spa json supports "args", module configuration must be done via lua syntax
          # see https://gitlab.freedesktop.org/pipewire/wireplumber/-/issues/45
          mapComponent = comp: if comp.arguments == null
            then comp.out.component
            else { name = luaComponent comp; type = "config/lua"; };
          components = map mapComponent cfg.components;
        in mkMerge [
          (mkBefore prelude)
          components
        ];
      };
    };
    environment.systemPackages = mkIf cfg.enable [ cfg.package ];
    systemd.packages = mkIf cfg.enable [ cfg.package ];
    systemd.user.services.wireplumber = mkIf cfg.enable {
      #serviceConfig.ExecStart = [ "" "${cfg.package}/bin/wireplumber -c ${cfg.service.configFile}" ]; # empty line clears the default
      environment = {
        WIREPLUMBER_DATA_DIR = cfg.service.dataDir;
        WIREPLUMBER_CONFIG_DIR = "${pkgs.linkFarm "wireplumber.conf" [ {
          name = "wireplumber.conf";
          path = cfg.service.configFile;
        } ]}";
        WIREPLUMBER_MODULE_DIR = mkIf (cfg.moduleDir != null) cfg.moduleDir;
        # SPA_PLUGIN_DIR, PIPEWIRE_MODULE_DIR ?
      };
      wantedBy = singleton "pipewire.service";
    };
  };
}
