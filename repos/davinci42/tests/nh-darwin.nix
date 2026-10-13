{
  pkgs ? import <nixpkgs> { system = "aarch64-darwin"; },
  darwin ? <darwin>,
}:
let
  inherit (pkgs) lib;
  module = (import ../default.nix { pkgs = null; }).darwinModules.nh;
  evaluate =
    extra:
    (import (darwin + "/eval-config.nix") {
      inherit lib;
      modules = [
        module
        {
          nixpkgs.pkgs = pkgs;
          system.stateVersion = 6;
        }
        extra
      ];
    }).config;
  disabled = evaluate { };
  enabled = evaluate { programs.nh.enable = true; };
  cleanOnly = evaluate { programs.nh.clean.enable = true; };
  custom = evaluate {
    programs.nh = {
      enable = true;
      package = pkgs.hello;
      flake = "/Users/test user/nix-config";
      clean = {
        enable = true;
        interval = [
          {
            Hour = 23;
            Minute = 0;
          }
          {
            Weekday = 1;
            Hour = 8;
            Minute = 30;
          }
        ];
        extraArgs = "--no-direnv --keep 3 --keep-since 7d";
      };
    };
    nix.package = pkgs.nixVersions.latest;
  };
  conflict = evaluate {
    programs.nh.clean.enable = true;
    nix.gc.automatic = true;
  };
  invalidFlake = evaluate { programs.nh.flake = "/tmp/flake.nix"; };
  dormantFlake = evaluate { programs.nh.flake = "/tmp/config"; };
  emptyArgs = evaluate {
    programs.nh.clean = {
      enable = true;
      extraArgs = "";
    };
  };
  invalidInterval = evaluate { programs.nh.clean.interval = "23:00"; };
  invalidArgs = evaluate { programs.nh.clean.extraArgs = "--keep 3\n--no-direnv"; };
  daemon = custom.launchd.daemons.nh-clean;
  defaultDaemon = cleanOnly.launchd.daemons.nh-clean;
  hasFailure =
    fragment: configuration:
    lib.any (item: !item.assertion && lib.hasInfix fragment item.message) configuration.assertions;
  checks = {
    moduleWithoutPkgs = builtins.isPath module;
    disabledByDefault = !disabled.programs.nh.enable && !disabled.programs.nh.clean.enable;
    disabledDaemon = !(disabled.launchd.daemons ? nh-clean);
    disabledPackage = !(builtins.elem pkgs.nh disabled.environment.systemPackages);
    disabledEnvironment = !(dormantFlake.environment.variables ? NH_FLAKE);
    packageDefault = enabled.programs.nh.package == pkgs.nh;
    enabledPackage = builtins.elem pkgs.nh enabled.environment.systemPackages;
    noImplicitCleanup = !(enabled.launchd.daemons ? nh-clean);
    noImplicitFlake = !(enabled.environment.variables ? NH_FLAKE);
    customPackage = builtins.elem pkgs.hello custom.environment.systemPackages;
    customFlake = custom.environment.variables.NH_FLAKE == "/Users/test user/nix-config";
    cleanIndependent = !cleanOnly.programs.nh.enable && cleanOnly.launchd.daemons ? nh-clean;
    preservesDirenv = cleanOnly.programs.nh.clean.extraArgs == "--no-direnv";
    defaultCommand =
      defaultDaemon.command == "${lib.escapeShellArg (lib.getExe pkgs.nh)} clean all --no-direnv";
    defaultWeeklySchedule =
      map (lib.filterAttrs (_: value: value != null)) defaultDaemon.serviceConfig.StartCalendarInterval
      == [
        {
          Weekday = 7;
          Hour = 3;
          Minute = 15;
        }
      ];
    customCommand =
      daemon.command
      == "${lib.escapeShellArg (lib.getExe pkgs.hello)} clean all --no-direnv --keep 3 --keep-since 7d";
    customSchedule = daemon.serviceConfig.StartCalendarInterval == custom.programs.nh.clean.interval;
    callerNixOnPath = lib.hasPrefix "${custom.nix.package}/bin:" daemon.path;
    systemToolsOnPath = lib.hasSuffix ":/usr/bin:/bin:/usr/sbin:/sbin" daemon.path;
    daemonEnvironment = daemon.serviceConfig.EnvironmentVariables.PATH == daemon.path;
    runsAsRoot = daemon.serviceConfig.UserName == "root";
    noCleanupOnActivation = !daemon.serviceConfig.RunAtLoad;
    noContinuousCleanup = daemon.serviceConfig.KeepAlive != true;
    launcher =
      daemon.serviceConfig.ProgramArguments == [
        "/bin/sh"
        "-c"
        "/bin/wait4path /nix/store && exec ${daemon.command}"
      ];
    plistGenerated =
      lib.hasInfix "<string>root</string>"
        custom.environment.launchDaemons."org.nixos.nh-clean.plist".text;
    argsCanBeReplaced =
      emptyArgs.launchd.daemons.nh-clean.command
      == "${lib.escapeShellArg (lib.getExe pkgs.nh)} clean all ";
    rejectsConcurrentGc = hasFailure "not both" conflict;
    acceptsSingleCleaner = !(hasFailure "not both" custom);
    rejectsNixFile = hasFailure "not a Nix file" invalidFlake;
    rejectsSystemdSchedule = !(builtins.tryEval invalidInterval.programs.nh.clean.interval).success;
    rejectsMultilineArgs = !(builtins.tryEval invalidArgs.programs.nh.clean.extraArgs).success;
  };
  failures = lib.attrNames (lib.filterAttrs (_: passed: !passed) checks);
in
assert lib.assertMsg pkgs.stdenv.hostPlatform.isDarwin
  "These evaluation tests require a Darwin target package set, not a Darwin host.";
assert lib.assertMsg (failures == [ ]) "Failed checks: ${lib.concatStringsSep ", " failures}";
checks
