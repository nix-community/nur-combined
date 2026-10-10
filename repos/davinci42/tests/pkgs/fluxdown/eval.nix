{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
  evaluate =
    extra:
    (import (pkgs.path + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      system = pkgs.stdenv.hostPlatform.system;
      modules = [
        ../../../modules/fluxdown.nix
        extra
      ];
    }).config;
  disabled = evaluate { };
  enabled = evaluate { services.fluxdown.enable = true; };
  custom = evaluate {
    services.fluxdown = {
      enable = true;
      package = pkgs.hello;
      listenAddress = "[::1]";
      port = 18000;
      openFirewall = true;
      environment = {
        FLUXDOWN_LANG = "zh";
        FLUXDOWN_ANALYTICS = "true";
        FLUXDOWN_SAVE_DIR = "/srv/downloads";
      };
      environmentFile = "/run/secrets/fluxdown.env";
    };
  };
  conflicts =
    name: value:
    evaluate {
      services.fluxdown = {
        enable = true;
        environment.${name} = value;
      };
    };
  invalidFile = evaluate {
    services.fluxdown = {
      enable = true;
      environmentFile = "relative.env";
    };
  };
  schema = builtins.fromJSON (builtins.readFile ../../../pkgs/fluxdown-server/settings-schema.json);
  writable = lib.filterAttrs (_: field: field.kind != "ReadOnly") schema.fields;
  allDefaults = lib.mapAttrs (
    _: field:
    if
      builtins.elem field.kind [
        "Bool"
        "Integer"
        "Float"
      ]
    then
      builtins.fromJSON field.default
    else
      field.default
  ) writable;
  configured = evaluate {
    services.fluxdown = {
      enable = true;
      settings = allDefaults // {
        upload_limit_bytes = 1048576;
        bt_enabled = false;
        file_exists_behavior = "ask";
      };
      settingsFile = "/run/secrets/fluxdown-settings.json";
    };
  };
  invalidSetting =
    name: value:
    let
      result = evaluate { services.fluxdown.settings.${name} = value; };
    in
    !(builtins.tryEval (builtins.deepSeq result.services.fluxdown.settings true)).success;
  wrongVersion = evaluate {
    services.fluxdown = {
      enable = true;
      package = pkgs.hello;
      settings.upload_limit_bytes = 1;
    };
  };
  checks = {
    allWritableSettings =
      builtins.attrNames enabled.services.fluxdown.settings == builtins.attrNames writable;
    allDefaultsValid =
      builtins.deepSeq
        (evaluate {
          services.fluxdown.settings = allDefaults;
        }).services.fluxdown.settings
        true;
    btDisabled = configured.services.fluxdown.settings.bt_enabled == false;
    askOnFileConflict = configured.services.fluxdown.settings.file_exists_behavior == "ask";
    omittedSettingsUnmanaged = lib.all (value: value == null) (
      builtins.attrValues enabled.services.fluxdown.settings
    );
    noSettingsHookByDefault = enabled.systemd.services.fluxdown.postStart == "";
    settingsHook =
      lib.hasInfix "fluxdown-configure.py" configured.systemd.services.fluxdown.postStart
      && lib.hasInfix "--settings-file" configured.systemd.services.fluxdown.postStart;
    rejectUnknownSetting = invalidSetting "unknown" 1;
    rejectReadonlySetting = invalidSetting "domain_conn_caps" "x";
    rejectNegativeLimit = invalidSetting "upload_limit_bytes" (-1);
    rejectBooleanLimit = invalidSetting "upload_limit_bytes" true;
    rejectInvalidEnum = invalidSetting "bt_mse_mode" "unknown";
    rejectStringBoolean = invalidSetting "bt_enable_upnp" "false";
    rejectStringBtEnabled = invalidSetting "bt_enabled" "false";
    rejectInvalidFileConflict = invalidSetting "file_exists_behavior" "unknown";
    rejectRange = invalidSetting "max_concurrent_tasks" 1025;
    rejectNegativeFloat = invalidSetting "bt_seed_ratio_limit" (-0.1);
    rejectVersionDrift = lib.any (
      item: !item.assertion && lib.hasPrefix "FluxDown settings schema" item.message
    ) wrongVersion.assertions;
    moduleWithoutPkgs =
      builtins.isPath
        (import ../../../default.nix { pkgs = null; }).nixosModules.fluxdown;
    disabledService = !(disabled.systemd.services ? fluxdown);
    disabledUser = !(disabled.users.users ? fluxdown);
    packageDefault = disabled.services.fluxdown.package.pname == "fluxdown-server";
    defaultBind = enabled.systemd.services.fluxdown.environment.FLUXDOWN_BIND == "127.0.0.1:17800";
    firewallClosed = enabled.networking.firewall.allowedTCPPorts == [ ];
    noSecretFile = !(enabled.systemd.services.fluxdown.serviceConfig ? EnvironmentFile);
    privateDefaults =
      enabled.systemd.services.fluxdown.environment.FLUXDOWN_ANALYTICS == "false"
      && enabled.systemd.services.fluxdown.environment.FLUXDOWN_MDNS == "false";
    customBind = custom.systemd.services.fluxdown.environment.FLUXDOWN_BIND == "[::1]:18000";
    firewallOpen = custom.networking.firewall.allowedTCPPorts == [ 18000 ];
    customEnvironment =
      custom.systemd.services.fluxdown.environment.FLUXDOWN_LANG == "zh"
      && custom.systemd.services.fluxdown.environment.FLUXDOWN_ANALYTICS == "true"
      && custom.systemd.services.fluxdown.environment.FLUXDOWN_SAVE_DIR == "/srv/downloads";
    customPackage =
      custom.systemd.services.fluxdown.serviceConfig.ExecStart
      == "${pkgs.hello}/bin/fluxdown-agent --server";
    secretFile =
      custom.systemd.services.fluxdown.serviceConfig.EnvironmentFile == "/run/secrets/fluxdown.env";
    rejectRelativeFile = !(builtins.tryEval invalidFile.services.fluxdown.environmentFile).success;
    rejectBindConflict =
      !(builtins.tryEval (conflicts "FLUXDOWN_BIND" "0.0.0.0:9999")
        .systemd.services.fluxdown.environment.FLUXDOWN_BIND).success;
    rejectDataConflict =
      !(builtins.tryEval (conflicts "FLUXDOWN_DATA_DIR" "/tmp/state")
        .systemd.services.fluxdown.environment.FLUXDOWN_DATA_DIR).success;
  };
  failures = lib.attrNames (lib.filterAttrs (_: passed: !passed) checks);
in
assert lib.assertMsg (failures == [ ]) "Failed checks: ${lib.concatStringsSep ", " failures}";
checks
