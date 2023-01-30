{ config, options, lib, ... }: with lib; let
  # https://www.mankier.com/5/saveconfig.json#Layout
  cfg = config.services.target;
  arg = import ../../canon.nix { inherit pkgs lib; };
  json = lib.json or arc.lib.json;
  fabricModule = { config, name, ... }: {
    freeformType = json.types.attrs;
    options = with types; {
      name = mkOption {
        type = str;
        default = name;
      };
    };
  };
  storageObject = { config, name, ... }: {
    freeformType = json.types.attrs;
    options = with types; {
      plugin = mkOption {
        type = enum [ "fileio" "block" "pscsi" "ramdisk" ];
      };
      name = mkOption {
        type = str;
        default = name;
      };
      storage_object = mkOption {
        type = str;
        default = "/backstores/${config.plugin}/${config.name}";
      };
    };
  };
  toStorageObject = so: removeAttrs so [ "storage_object" ];
  target = { config, name, ... }: {
    freeformType = json.types.attrs;
    options = with types; {
      name = mkOption {
        type = str;
        default = name;
      };
      wwn = mkOption {
        type = str;
        default = "${cfg.iqn.wwn}:${config.name}";
      };
      fabric = mkOption {
        type = str;
        default = "iscsi";
      };
      portGroups = mkOption {
        type = attrsOf (submodule [
          portGroup
          { config._module.args.target = config; }
        ]);
        default = { };
      };
    };
  };
  toTarget = target: {
    ${if target.portGroups != { } then "tpgs" else null} = map toPortGroup (attrValues target.portGroups);
  } // removeAttrs target [ "portGroups" "name" ];
  portGroup = { config, name, ... }: {
    freeformType = json.types.attrs;
    options = with types; {
      enable = mkOption {
        type = bool;
        default = true;
      };
      lun = mkOption {
        type = attrsOf (submodule lun);
        default = { };
      };
      portal = mkOption {
        type = attrsOf (submodule portal);
        default = { };
      };
      node = mkOption {
        type = attrsOf (submodule [
          nodeACLs
          { config._module.args.tpg = config; }
        ]);
        default = { };
      };
    };
  };
  toPortGroup = tpg: {
    ${if tpg.lun != { } then "luns" else null} = sorted (map toLUN (attrValues tpg.lun));
    ${if tpg.portal != { } then "portals" else null} = sorted (map toLUN (attrValues tpg.portal));
    ${if tpg.node != { } then "node_acls" else null} = sortBy "tag" (map toNodeACL (attrValues tpg.node));
  } // removeAttrs tpg [ "lun" "portal" "node" ];
  lun = { config, name, ... }: {
    freeformType = json.types.attrs;
    options = with types; {
      index = mkOption {
        type = int;
      };
      storage_object = mkOption {
        type = strMatching "/backstores/.*";
      };
    };
    config = {
      storage_object = mkIf (cfg.storageObjects ? ${name}) (
        mkOptionDefault cfg.storageObjects.${name}.storage_object
      );
    };
  };
  toLUN = id;
  portal = { config, name, ... }: {
    freeformType = json.types.attrs;
    options = with types; {
      ip_address = mkOption {
        type = str;
        default = name;
      };
      port = mkOption {
        type = port;
        default = 3260;
      };
    };
  };
  toPortal = id;
  nodeACLs = { tpg, config, name, ... }: {
    freeformType = json.types.attrs;
    options = with types; {
      name = mkOption {
        type = str;
        default = name;
      };
      node_wwn = mkOption {
        type = str;
        default = "${cfg.iqn.wwn}:${config.name}";
      };
      lun = mkOption {
        type = attrsOf (submodule [
          mappedLUN
          {
            config._module.args = {
              inherit tpg;
            };
          }
        ]);
        default = { };
      };
    };
  };
  toNodeACL = node: {
    ${if node.lun != { } then "mapped_luns" else null} = sorted (map toMappedLUN (attrValues node.lun));
  } // removeAttrs node [ "lun" "name" ];
  mappedLUN = { tpg, config, name, ... }: {
    freeformType = json.types.attrs;
    options = with types; {
      index = mkOption {
        type = int;
        default = config.tpg_lun;
      };
      tpg_lun = mkOption {
        type = int;
      };
      write_protect = mkOption {
        type = bool;
        default = false;
      };
    };
    config = {
      tpg_lun = mkIf (tpg.lun ? ${name}) (mkOptionDefault tpg.lun.${name}.index);
    };
  };
  toMappedLUN = id;
  sortBy = key: sort (a: b: a.${key} or 0 < b.${key} or 0);
  sorted = sortBy "index";
in {
  options.services.target = with types; {
    settings = mkOption {
      type = json.types.attrs;
      default = { };
      description = "https://www.mankier.com/5/saveconfig.json#Layout";
    };
    fabricModules = mkOption {
      type = attrsOf (submodule fabricModule);
      default = { };
    };
    storageObjects = mkOption {
      type = attrsOf (submodule storageObject);
      default = { };
    };
    targets = mkOption {
      type = attrsOf (submodule target);
      default = { };
    };
    iqn = let
      stateVersion = splitString "." config.system.stateVersion;
    in {
      year = mkOption {
        type = strMatching "[0-9]{4}";
        default = "20" + elemAt stateVersion 0;
      };
      month = mkOption {
        type = strMatching "[0-9]{2}";
        default = elemAt stateVersion 1;
      };
      authorityName = mkOption {
        type = str;
        default = let
          inherit (config) networking;
        in if networking.domain != null then networking.domain else networking.hostName;
      };
      namingAuthority = mkOption {
        type = str;
        default = let
          components = splitString "." cfg.iqn.authorityName;
        in concatStringsSep "." (reverseList components);
      };
      wwn = mkOption {
        type = str;
        default = "iqn.${cfg.iqn.year}-${cfg.iqn.month}.${cfg.iqn.namingAuthority}";
      };
    };
  };
  config.services.target = {
    config = mkIf (cfg.settings != { }) cfg.settings;
    settings = {
      fabric_modules = mkIf (cfg.fabricModules != { }) (
        attrValues cfg.fabricModules
      );
      storage_objects = mkIf (cfg.storageObjects != { }) (
        map toStorageObject (attrValues cfg.storageObjects)
      );
      targets = mkIf (cfg.targets != { }) (
        map toTarget (attrValues cfg.targets)
      );
    };
    fabricModules = mkMerge (mapAttrsToList (_: target: { ${target.fabric} = { }; }) cfg.targets);
  };
}
