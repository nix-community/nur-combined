{
  lib,
  commonConfig,
  renderSystemdCommand,
  resolveAccount,
}: spec: let
  account = resolveAccount "nixos" spec.account;

  accountConfig = lib.optionalAttrs (account != null && account.manage) {
    users.groups.${account.groupName} = account.platformAccount.groupConfig;

    users.users.${account.userName} =
      lib.recursiveUpdate {
        inherit (account) description;
        isSystemUser = true;
        group = account.groupName;
        home = account.home;
        createHome = account.createHome;
      }
      account.platformAccount.userConfig;
  };

  generatedService = {
    inherit (spec) description;
    wantedBy =
      if spec.nixos.wantedBy != null
      then spec.nixos.wantedBy
      else lib.optional spec.lifecycle.autostart "multi-user.target";
    inherit (spec.nixos) wants requires after;
    environment = spec.process.environment;

    serviceConfig = lib.filterAttrs (_: value: value != null) ({
        ExecStart = renderSystemdCommand spec.process;
        WorkingDirectory = spec.process.workingDirectory;
        User =
          if account == null
          then null
          else account.userName;
        Group =
          if account == null
          then null
          else account.groupName;
        Restart = spec.lifecycle.restart;
        RestartSec =
          if spec.lifecycle.restart == "no"
          then null
          else spec.lifecycle.restartBackoffSeconds;
        TimeoutStopSec = spec.lifecycle.stopTimeoutSeconds;
        UMask = spec.process.umask;
      }
      // spec.nixos.serviceConfig);
  };

  serviceConfig = lib.recursiveUpdate generatedService spec.nixos.extraConfig;
in
  lib.mkMerge [
    (commonConfig spec)
    accountConfig
    {systemd.services.${spec.name} = serviceConfig;}
  ]
